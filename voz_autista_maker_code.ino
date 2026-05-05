// ============================================================
// Voz Autista v2.0 - Comunicador Assistivo
// Dispositivo de Comunicação para pessoas com autismo
// ============================================================
//
// MELHORIAS v2.0:
//   - 7 categorias com 35 palavras (era 3 com 15)
//   - Controle de volume por potenciômetro (A0)
//   - Detecção automática do endereço I2C do LCD
//   - Monitoramento de bateria com ícone no LCD (A1)
//   - Modo frase composta (empilhar palavras)
//   - Feedback tátil por vibração (D7)
//   - Modo sleep após inatividade
//   - Seção de configuração fácil de editar
//
// PINAGEM:
//   D2  → Botão Vermelho (Cat+)     → GND
//   D3  → Botão Amarelo  (Cat-)     → GND
//   D4  → Botão Verde    (Pal+)     → GND
//   D5  → Botão Azul     (Pal-)     → GND
//   D6  → Botão Preto    (FALAR)    → GND
//   D7  → Transistor NPN → Motor vibração
//   D10 ← DFPlayer TX
//   D11 → 1kΩ → DFPlayer RX
//   A0  ← Potenciômetro (volume)
//   A1  ← Divisor tensão bateria (10k+10k)
//   A4  → LCD SDA (I2C)
//   A5  → LCD SCL (I2C)
//
// CARTÃO SD (pasta por categoria):
//   /01/001-005.mp3  Necessidades
//   /02/001-005.mp3  Sentimentos
//   /03/001-005.mp3  Ações
//   /04/001-005.mp3  Comidas
//   /05/001-005.mp3  Lugares
//   /06/001-005.mp3  Pessoas
//   /07/001-005.mp3  Saúde
// ============================================================

#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <SoftwareSerial.h>
#include <DFRobotDFPlayerMini.h>

// =============================================================
// ██  SEÇÃO DE CONFIGURAÇÃO - EDITE AQUI PARA PERSONALIZAR  ██
// =============================================================
// Para adicionar/alterar categorias:
//   1. Edite o array 'categories[]' abaixo
//   2. Atualize NUM_CATEGORIES
//   3. Crie a pasta correspondente no SD card (/0X/)
//   4. Grave os MP3s como 001.mp3 a 005.mp3 em cada pasta
//
// Para alterar nomes dos botões, mude os labels no LCD.
// Para alterar a ordem dos botões, mude os pinos abaixo.
// =============================================================

// --- Estrutura de categoria ---
struct Category {
  const char* name;       // Nome exibido no LCD (máx 14 chars)
  const char* words[5];   // Até 5 palavras por categoria
  int numWords;           // Quantas palavras tem (1-5)
};

// --- CATEGORIAS E PALAVRAS ---
// Pasta do SD = índice da categoria + 1
// Arquivo do SD = índice da palavra + 1
// Ex: categories[2].words[3] → /03/004.mp3
Category categories[] = {
  // Categoria 0 → pasta /01/
  {"Necessidades", {"Eu quero", "Comer", "Beber", "Banheiro", "Dormir"}, 5},

  // Categoria 1 → pasta /02/
  {"Sentimentos",  {"Feliz", "Triste", "Bravo", "Calmo", "Medo"},        5},

  // Categoria 2 → pasta /03/
  {"Acoes",        {"Brincar", "Ajuda", "Sair", "Parar", "Ir"},          5},

  // Categoria 3 → pasta /04/
  {"Comidas",      {"Agua", "Suco", "Leite", "Pao", "Fruta"},            5},

  // Categoria 4 → pasta /05/
  {"Lugares",      {"Casa", "Escola", "Parque", "Medico", "Banho"},       5},

  // Categoria 5 → pasta /06/
  {"Pessoas",      {"Mamae", "Papai", "Vovo", "Professor", "Amigo"},      5},

  // Categoria 6 → pasta /07/
  {"Saude",        {"Doi", "Enjoo", "Frio", "Calor", "Cansado"},         5}
};

const int NUM_CATEGORIES = sizeof(categories) / sizeof(categories[0]);

// --- Pinos ---
const int btnCatUp     = 2;   // Vermelho - Categoria +
const int btnCatDown   = 3;   // Amarelo  - Categoria -
const int btnWordUp    = 4;   // Verde    - Palavra +
const int btnWordDown  = 5;   // Azul     - Palavra -
const int btnSpeak     = 6;   // Preto    - FALAR
const int pinVibrate   = 7;   // Motor de vibração
const int pinVolume    = A0;  // Potenciômetro de volume
const int pinBattery   = A1;  // Divisor de tensão da bateria

// --- Tempos (ms) ---
const unsigned long DEBOUNCE_DELAY   = 250;
const unsigned long LONG_PRESS_TIME  = 800;   // Tempo para press longo
const unsigned long SLEEP_TIMEOUT    = 120000; // 2 min para dormir
const unsigned long VOLUME_INTERVAL  = 500;    // Intervalo leitura volume
const unsigned long BATTERY_INTERVAL = 10000;  // Intervalo leitura bateria
const int VIBRATE_MS = 60;                     // Duração vibração (ms)
const int PHRASE_DELAY = 1300;                 // Pausa entre palavras da frase

// --- Tamanho máximo da frase composta ---
const int MAX_PHRASE = 5;

// =============================================================
// ██  FIM DA SEÇÃO DE CONFIGURAÇÃO                           ██
// =============================================================

// --- DFPlayer ---
SoftwareSerial dfSerial(10, 11);
DFRobotDFPlayerMini dfPlayer;
bool dfPlayerReady = false;

// --- LCD (criado dinamicamente após detecção I2C) ---
LiquidCrystal_I2C* lcd = nullptr;

// --- Estado de navegação ---
int catIndex  = 0;
int wordIndex = 0;
int volume    = 20;

// --- Frase composta ---
struct PhraseWord {
  byte cat;
  byte word;
};
PhraseWord phraseBuffer[MAX_PHRASE];
int phraseCount = 0;

// --- Temporização ---
unsigned long lastButtonTime   = 0;
unsigned long lastVolumeTime   = 0;
unsigned long lastBatteryTime  = 0;
unsigned long lastActivityTime = 0;

// --- Botão FALAR (detecção long press) ---
bool speakBtnPrev        = false;
unsigned long speakPressStart = 0;

// --- Sleep ---
bool isSleeping = false;

// --- Bateria ---
int batteryPercent = 100;

// --- Caracteres customizados LCD ---
byte charArrow[8]   = {0x00,0x04,0x06,0x1F,0x1F,0x06,0x04,0x00};
byte charSpeaker[8] = {0x01,0x03,0x0F,0x0F,0x0F,0x03,0x01,0x00};
byte charBatFull[8] = {0x0E,0x1F,0x1F,0x1F,0x1F,0x1F,0x1F,0x1F};
byte charBatMid[8]  = {0x0E,0x11,0x11,0x1F,0x1F,0x1F,0x1F,0x1F};
byte charBatLow[8]  = {0x0E,0x11,0x11,0x11,0x11,0x11,0x1F,0x1F};
byte charPhrase[8]  = {0x00,0x0A,0x1F,0x1F,0x0E,0x04,0x00,0x00}; // coração = tem frase

// ===================== SETUP =====================
void setup() {
  Serial.begin(9600);
  dfSerial.begin(9600);

  // Pinos
  pinMode(btnCatUp,   INPUT_PULLUP);
  pinMode(btnCatDown,  INPUT_PULLUP);
  pinMode(btnWordUp,   INPUT_PULLUP);
  pinMode(btnWordDown, INPUT_PULLUP);
  pinMode(btnSpeak,    INPUT_PULLUP);
  pinMode(pinVibrate,  OUTPUT);
  digitalWrite(pinVibrate, LOW);

  // Detecta endereço I2C do LCD
  byte lcdAddr = detectI2C();
  lcd = new LiquidCrystal_I2C(lcdAddr, 16, 2);
  lcd->init();
  lcd->backlight();

  // Caracteres customizados
  lcd->createChar(0, charArrow);
  lcd->createChar(1, charSpeaker);
  lcd->createChar(2, charBatFull);
  lcd->createChar(3, charBatMid);
  lcd->createChar(4, charBatLow);
  lcd->createChar(5, charPhrase);

  // Splash
  lcd->setCursor(2, 0);
  lcd->print(F("Voz Autista"));
  lcd->setCursor(2, 1);
  lcd->print(F("v2.0  Maker"));
  Serial.print(F("LCD I2C addr: 0x"));
  Serial.println(lcdAddr, HEX);

  // Volume inicial do potenciômetro
  volume = map(analogRead(pinVolume), 0, 1023, 0, 30);

  // DFPlayer
  delay(1000);
  if (dfPlayer.begin(dfSerial)) {
    dfPlayerReady = true;
    dfPlayer.outputDevice(DFPLAYER_DEVICE_SD);
    dfPlayer.volume(volume);
    Serial.println(F("DFPlayer OK"));
  } else {
    Serial.println(F("DFPlayer ERRO"));
    lcd->clear();
    lcd->print(F("ERRO: DFPlayer"));
    lcd->setCursor(0, 1);
    lcd->print(F("Cheque SD/fios"));
    delay(2500);
  }

  // Bateria inicial
  batteryPercent = readBattery();

  // Info serial
  Serial.print(F("Categorias: "));
  Serial.println(NUM_CATEGORIES);
  Serial.print(F("Volume: "));
  Serial.println(volume);

  lastActivityTime = millis();
  delay(800);
  lcd->clear();
  displaySelection();
}

// ===================== LOOP =====================
void loop() {
  unsigned long now = millis();

  // --- Sleep check ---
  if (!isSleeping && (now - lastActivityTime > SLEEP_TIMEOUT)) {
    enterSleep();
    return;
  }
  if (isSleeping) {
    // Qualquer botão acorda
    if (anyButtonPressed()) {
      wakeUp();
    }
    delay(50);
    return;
  }

  // --- Volume (potenciômetro) ---
  if (now - lastVolumeTime > VOLUME_INTERVAL) {
    updateVolume();
    lastVolumeTime = now;
  }

  // --- Bateria ---
  if (now - lastBatteryTime > BATTERY_INTERVAL) {
    batteryPercent = readBattery();
    displayBattery();
    lastBatteryTime = now;
  }

  // --- Debounce ---
  if (now - lastButtonTime < DEBOUNCE_DELAY) {
    // Botão FALAR precisa tracking contínuo mesmo durante debounce
    trackSpeakButton(now);
    return;
  }

  // --- Combos especiais (verificar ANTES dos individuais) ---
  bool catUpDown   = (digitalRead(btnCatUp) == LOW && digitalRead(btnCatDown) == LOW);
  bool wordUpDown  = (digitalRead(btnWordUp) == LOW && digitalRead(btnWordDown) == LOW);

  if (catUpDown && phraseCount > 0) {
    // Cat+ e Cat- juntos = falar frase completa
    speakPhrase();
    lastButtonTime = now;
    lastActivityTime = now;
    return;
  }
  if (wordUpDown && phraseCount > 0) {
    // Pal+ e Pal- juntos = limpar frase
    clearPhrase();
    lastButtonTime = now;
    lastActivityTime = now;
    return;
  }

  // --- Navegação de categorias ---
  if (digitalRead(btnCatUp) == LOW) {
    catIndex = (catIndex + 1) % NUM_CATEGORIES;
    wordIndex = 0;
    vibrate();
    displaySelection();
    lastButtonTime = now;
    lastActivityTime = now;
  }
  else if (digitalRead(btnCatDown) == LOW) {
    catIndex = (catIndex - 1 + NUM_CATEGORIES) % NUM_CATEGORIES;
    wordIndex = 0;
    vibrate();
    displaySelection();
    lastButtonTime = now;
    lastActivityTime = now;
  }
  // --- Navegação de palavras ---
  else if (digitalRead(btnWordUp) == LOW) {
    int n = categories[catIndex].numWords;
    wordIndex = (wordIndex + 1) % n;
    vibrate();
    displaySelection();
    lastButtonTime = now;
    lastActivityTime = now;
  }
  else if (digitalRead(btnWordDown) == LOW) {
    int n = categories[catIndex].numWords;
    wordIndex = (wordIndex - 1 + n) % n;
    vibrate();
    displaySelection();
    lastButtonTime = now;
    lastActivityTime = now;
  }

  // --- Botão FALAR (long press detection) ---
  trackSpeakButton(now);
}

// ===================== BOTÃO FALAR =====================
void trackSpeakButton(unsigned long now) {
  bool pressed = (digitalRead(btnSpeak) == LOW);

  if (pressed && !speakBtnPrev) {
    // Acabou de pressionar
    speakPressStart = now;
  }
  else if (!pressed && speakBtnPrev) {
    // Acabou de soltar
    unsigned long holdTime = now - speakPressStart;
    lastActivityTime = now;
    lastButtonTime = now;

    if (holdTime >= LONG_PRESS_TIME) {
      // Long press → adiciona à frase
      addToPhrase();
    } else {
      // Short press → fala imediatamente
      speakCurrentWord();
    }
  }
  speakBtnPrev = pressed;
}

// ===================== DISPLAY =====================
void displaySelection() {
  lcd->clear();

  // Linha 1: categoria + bateria
  lcd->setCursor(0, 0);
  lcd->print(categories[catIndex].name);
  displayBattery();

  // Linha 2: seta + palavra + indicador frase
  lcd->setCursor(0, 1);
  lcd->write(byte(0)); // seta
  lcd->print(' ');
  lcd->print(categories[catIndex].words[wordIndex]);

  // Indicador de frase (canto inferior direito)
  if (phraseCount > 0) {
    lcd->setCursor(14, 1);
    lcd->write(byte(5)); // coração
    lcd->print(phraseCount);
  }
}

void displayBattery() {
  lcd->setCursor(15, 0);
  if (batteryPercent > 60)
    lcd->write(byte(2));      // cheio
  else if (batteryPercent > 20)
    lcd->write(byte(3));      // meio
  else
    lcd->write(byte(4));      // baixo
}

// ===================== FALAR =====================
void speakCurrentWord() {
  const char* word = categories[catIndex].words[wordIndex];
  int folder = catIndex + 1;
  int file   = wordIndex + 1;

  vibrate();

  // Feedback visual
  lcd->clear();
  lcd->setCursor(0, 0);
  lcd->write(byte(1));
  lcd->print(F(" Falando..."));
  lcd->setCursor(0, 1);
  lcd->print(word);

  Serial.print(F("Falar: "));
  Serial.print(word);
  Serial.print(F(" [/0"));
  Serial.print(folder);
  Serial.print(F("/00"));
  Serial.print(file);
  Serial.println(F(".mp3]"));

  if (dfPlayerReady) {
    dfPlayer.playFolder(folder, file);
  }

  delay(600);
  displaySelection();
}

// ===================== FRASE COMPOSTA =====================
void addToPhrase() {
  if (phraseCount >= MAX_PHRASE) {
    // Buffer cheio - feedback
    lcd->clear();
    lcd->print(F("Frase cheia!"));
    lcd->setCursor(0, 1);
    lcd->print(F("Max "));
    lcd->print(MAX_PHRASE);
    lcd->print(F(" palavras"));
    vibrate();
    delay(50);
    vibrate();
    delay(1000);
    displaySelection();
    return;
  }

  phraseBuffer[phraseCount].cat  = catIndex;
  phraseBuffer[phraseCount].word = wordIndex;
  phraseCount++;

  vibrate();

  // Feedback visual
  lcd->clear();
  lcd->setCursor(0, 0);
  lcd->print(F("+ "));
  lcd->print(categories[catIndex].words[wordIndex]);
  lcd->setCursor(0, 1);
  lcd->print(F("Frase: "));
  lcd->print(phraseCount);
  lcd->print(F("/"));
  lcd->print(MAX_PHRASE);

  Serial.print(F("Frase +: "));
  Serial.print(categories[catIndex].words[wordIndex]);
  Serial.print(F(" ("));
  Serial.print(phraseCount);
  Serial.println(F(" palavras)"));

  delay(800);
  displaySelection();
}

void speakPhrase() {
  if (phraseCount == 0) return;

  vibrate();

  lcd->clear();
  lcd->setCursor(0, 0);
  lcd->write(byte(1));
  lcd->print(F(" Frase ("));
  lcd->print(phraseCount);
  lcd->print(F(")..."));

  Serial.print(F("Frase completa: "));

  for (int i = 0; i < phraseCount; i++) {
    int c = phraseBuffer[i].cat;
    int w = phraseBuffer[i].word;
    const char* word = categories[c].words[w];

    lcd->setCursor(0, 1);
    lcd->print(F("                ")); // limpa linha
    lcd->setCursor(0, 1);
    lcd->print(word);

    Serial.print(word);
    if (i < phraseCount - 1) Serial.print(F(" + "));

    if (dfPlayerReady) {
      dfPlayer.playFolder(c + 1, w + 1);
    }

    if (i < phraseCount - 1) {
      delay(PHRASE_DELAY);
    }
  }

  Serial.println();

  delay(800);

  // Limpa frase após falar
  phraseCount = 0;
  displaySelection();
}

void clearPhrase() {
  phraseCount = 0;
  vibrate();
  lcd->clear();
  lcd->print(F("Frase limpa"));
  Serial.println(F("Frase limpa"));
  delay(800);
  displaySelection();
}

// ===================== VOLUME =====================
void updateVolume() {
  int raw = analogRead(pinVolume);
  int newVol = map(raw, 0, 1023, 0, 30);
  if (abs(newVol - volume) > 1) {
    volume = newVol;
    if (dfPlayerReady) {
      dfPlayer.volume(volume);
    }
  }
}

// ===================== BATERIA =====================
int readBattery() {
  // Divisor de tensão: 10kΩ + 10kΩ → metade da voltagem
  // 18650: 4.2V (cheio) → 2.1V no A1 → ADC ~430
  //        3.0V (vazio) → 1.5V no A1 → ADC ~307
  int raw = analogRead(pinBattery);
  int pct = map(raw, 307, 430, 0, 100);
  return constrain(pct, 0, 100);
}

// ===================== VIBRAÇÃO =====================
void vibrate() {
  digitalWrite(pinVibrate, HIGH);
  delay(VIBRATE_MS);
  digitalWrite(pinVibrate, LOW);
}

// ===================== SLEEP =====================
void enterSleep() {
  isSleeping = true;
  lcd->noBacklight();
  Serial.println(F("Sleep"));
}

void wakeUp() {
  isSleeping = false;
  lcd->backlight();
  lastActivityTime = millis();
  lastButtonTime = millis(); // evita ação do botão que acordou
  displaySelection();
  Serial.println(F("Wake"));
  delay(200);
}

bool anyButtonPressed() {
  return (digitalRead(btnCatUp) == LOW ||
          digitalRead(btnCatDown) == LOW ||
          digitalRead(btnWordUp) == LOW ||
          digitalRead(btnWordDown) == LOW ||
          digitalRead(btnSpeak) == LOW);
}

// ===================== I2C AUTO DETECT =====================
byte detectI2C() {
  Wire.begin();
  byte addrs[] = {0x27, 0x3F, 0x20, 0x38};
  for (byte i = 0; i < 4; i++) {
    Wire.beginTransmission(addrs[i]);
    if (Wire.endTransmission() == 0) {
      Serial.print(F("I2C encontrado: 0x"));
      Serial.println(addrs[i], HEX);
      return addrs[i];
    }
  }
  Serial.println(F("I2C nao detectado, usando 0x27"));
  return 0x27;
}
