// ============================================================
// Voz Autista v2.0 - Simulacao Wokwi
// Comunicador Assistivo para pessoas com autismo
// ============================================================
//
// SIMULACAO WOKWI - Equivalencias:
//   DFPlayer Mini  -> Buzzer no pino D9
//   Motor vibracao -> LED verde no pino D7
//   Volume pot     -> Potenciometro em A0
//   Bateria        -> Potenciometro em A1
//   LCD I2C        -> LCD 16x2 I2C (0x27)
//
// PINAGEM (identica ao hardware real):
//   D2  -> Botao Vermelho (Cat+)   -> GND
//   D3  -> Botao Amarelo  (Cat-)   -> GND
//   D4  -> Botao Verde    (Pal+)   -> GND
//   D5  -> Botao Azul     (Pal-)   -> GND
//   D6  -> Botao Preto    (FALAR)  -> GND
//   D7  -> LED verde (simula vibracao)
//   D9  -> Buzzer (simula DFPlayer)
//   A0  <- Potenciometro (volume)
//   A1  <- Potenciometro (bateria)
//   A4  -> LCD SDA (I2C)
//   A5  -> LCD SCL (I2C)
//
// FUNCIONALIDADES v2.0:
//   - 7 categorias, 35 palavras
//   - Volume via potenciometro
//   - Bateria simulada com icone
//   - Frase composta (empilhar ate 5 palavras)
//   - Feedback tatil (LED simula vibracao)
//   - Sleep apos 2 min inatividade
//   - Caracteres customizados no LCD
// ============================================================

#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// --- LCD I2C (sempre 0x27 no Wokwi) ---
LiquidCrystal_I2C lcd(0x27, 16, 2);

// --- Pinos ---
const int btnCatUp    = 2;   // Vermelho - Categoria +
const int btnCatDown  = 3;   // Amarelo  - Categoria -
const int btnWordUp   = 4;   // Verde    - Palavra +
const int btnWordDown = 5;   // Azul     - Palavra -
const int btnSpeak    = 6;   // Preto    - FALAR
const int pinVibrate  = 7;   // LED verde (simula motor vibracao)
const int buzzerPin   = 9;   // Buzzer (simula DFPlayer)
const int pinVolume   = A0;  // Potenciometro volume
const int pinBattery  = A1;  // Potenciometro bateria

// --- Estrutura de categoria ---
struct Category {
  const char* name;
  const char* words[5];
  int numWords;
};

// --- CATEGORIAS E PALAVRAS (7 categorias x 5 palavras = 35) ---
Category categories[] = {
  // Categoria 0
  {"Necessidades", {"Eu quero", "Comer", "Beber", "Banheiro", "Dormir"}, 5},
  // Categoria 1
  {"Sentimentos",  {"Feliz", "Triste", "Bravo", "Calmo", "Medo"},       5},
  // Categoria 2
  {"Acoes",        {"Brincar", "Ajuda", "Sair", "Parar", "Ir"},         5},
  // Categoria 3
  {"Comidas",      {"Agua", "Suco", "Leite", "Pao", "Fruta"},           5},
  // Categoria 4
  {"Lugares",      {"Casa", "Escola", "Parque", "Medico", "Banho"},      5},
  // Categoria 5
  {"Pessoas",      {"Mamae", "Papai", "Vovo", "Professor", "Amigo"},     5},
  // Categoria 6
  {"Saude",        {"Doi", "Enjoo", "Frio", "Calor", "Cansado"},        5}
};

const int NUM_CATEGORIES = sizeof(categories) / sizeof(categories[0]);

// --- Tons para simulacao (7 categorias x 5 palavras = 35 tons) ---
const int tones[] = {
  262, 294, 330, 349, 392,        // Necessidades
  440, 494, 523, 587, 659,        // Sentimentos
  698, 784, 880, 988, 1047,       // Acoes
  1100, 1175, 1250, 1320, 1400,   // Comidas
  300, 350, 400, 450, 500,        // Lugares
  550, 600, 650, 700, 750,        // Pessoas
  800, 850, 900, 950, 1000        // Saude
};

// --- Tempos (ms) ---
const unsigned long DEBOUNCE_DELAY   = 250;
const unsigned long LONG_PRESS_TIME  = 800;
const unsigned long SLEEP_TIMEOUT    = 120000;  // 2 minutos
const unsigned long VOLUME_INTERVAL  = 500;
const unsigned long BATTERY_INTERVAL = 10000;
const int VIBRATE_MS    = 60;
const int PHRASE_DELAY  = 1300;

// --- Frase composta ---
const int MAX_PHRASE = 5;
struct PhraseWord {
  byte cat;
  byte word;
};
PhraseWord phraseBuffer[MAX_PHRASE];
int phraseCount = 0;

// --- Estado ---
int catIndex  = 0;
int wordIndex = 0;
int volume    = 20;
int batteryPercent = 100;

// --- Temporizacao ---
unsigned long lastButtonTime   = 0;
unsigned long lastVolumeTime   = 0;
unsigned long lastBatteryTime  = 0;
unsigned long lastActivityTime = 0;

// --- Botao FALAR (long press) ---
bool speakBtnPrev = false;
unsigned long speakPressStart = 0;

// --- Sleep ---
bool isSleeping = false;

// --- Caracteres customizados LCD ---
byte charArrow[8]   = {0x00, 0x04, 0x06, 0x1F, 0x1F, 0x06, 0x04, 0x00};
byte charSpeaker[8] = {0x01, 0x03, 0x0F, 0x0F, 0x0F, 0x03, 0x01, 0x00};
byte charBatFull[8] = {0x0E, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F};
byte charBatMid[8]  = {0x0E, 0x11, 0x11, 0x1F, 0x1F, 0x1F, 0x1F, 0x1F};
byte charBatLow[8]  = {0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x1F, 0x1F};
byte charPhrase[8]  = {0x00, 0x0A, 0x1F, 0x1F, 0x0E, 0x04, 0x00, 0x00};

// ===================== FUNCOES AUXILIARES =====================

// Stub para auto-detect I2C (no Wokwi sempre retorna 0x27)
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

void vibrate() {
  digitalWrite(pinVibrate, HIGH);
  delay(VIBRATE_MS);
  digitalWrite(pinVibrate, LOW);
}

bool anyButtonPressed() {
  return (digitalRead(btnCatUp) == LOW ||
          digitalRead(btnCatDown) == LOW ||
          digitalRead(btnWordUp) == LOW ||
          digitalRead(btnWordDown) == LOW ||
          digitalRead(btnSpeak) == LOW);
}

// ===================== SETUP =====================
void setup() {
  Serial.begin(115200);

  // Pinos dos botoes (INPUT_PULLUP: pressionar = LOW)
  pinMode(btnCatUp,    INPUT_PULLUP);
  pinMode(btnCatDown,  INPUT_PULLUP);
  pinMode(btnWordUp,   INPUT_PULLUP);
  pinMode(btnWordDown, INPUT_PULLUP);
  pinMode(btnSpeak,    INPUT_PULLUP);

  // Pino de vibracao (LED verde na simulacao)
  pinMode(pinVibrate, OUTPUT);
  digitalWrite(pinVibrate, LOW);

  // Buzzer
  pinMode(buzzerPin, OUTPUT);

  // Detecta LCD (stub - sempre 0x27 no Wokwi)
  byte lcdAddr = detectI2C();
  // No Wokwi o lcd ja foi criado com 0x27, ignoramos o retorno
  (void)lcdAddr;

  // Inicializa LCD
  lcd.init();
  lcd.backlight();

  // Caracteres customizados
  lcd.createChar(0, charArrow);
  lcd.createChar(1, charSpeaker);
  lcd.createChar(2, charBatFull);
  lcd.createChar(3, charBatMid);
  lcd.createChar(4, charBatLow);
  lcd.createChar(5, charPhrase);

  // Splash screen
  lcd.setCursor(2, 0);
  lcd.print(F("Voz Autista"));
  lcd.setCursor(2, 1);
  lcd.print(F("v2.0  Wokwi"));

  // Melodia de inicializacao
  tone(buzzerPin, 523, 100);
  delay(150);
  tone(buzzerPin, 659, 100);
  delay(150);
  tone(buzzerPin, 784, 200);
  delay(300);
  noTone(buzzerPin);

  // Volume inicial do potenciometro
  volume = map(analogRead(pinVolume), 0, 1023, 0, 30);

  // Bateria inicial
  batteryPercent = readBattery();

  // Info serial
  Serial.println(F("=== Voz Autista v2.0 - Simulacao Wokwi ==="));
  Serial.print(F("Categorias: "));
  Serial.println(NUM_CATEGORIES);
  Serial.print(F("Volume: "));
  Serial.println(volume);
  Serial.print(F("Bateria: "));
  Serial.print(batteryPercent);
  Serial.println(F("%"));
  Serial.println(F(""));
  Serial.println(F("Botoes: Cat+ Cat- Pal+ Pal- FALAR"));
  Serial.println(F("FALAR curto = fala palavra"));
  Serial.println(F("FALAR longo = adiciona a frase"));
  Serial.println(F("Cat+ & Cat- juntos = fala frase"));
  Serial.println(F("Pal+ & Pal- juntos = limpa frase"));
  Serial.println(F(""));

  lastActivityTime = millis();
  delay(1500);
  lcd.clear();
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
    if (anyButtonPressed()) {
      wakeUp();
    }
    delay(50);
    return;
  }

  // --- Volume (potenciometro A0) ---
  if (now - lastVolumeTime > VOLUME_INTERVAL) {
    updateVolume();
    lastVolumeTime = now;
  }

  // --- Bateria (potenciometro A1) ---
  if (now - lastBatteryTime > BATTERY_INTERVAL) {
    batteryPercent = readBattery();
    displayBattery();
    lastBatteryTime = now;
  }

  // --- Debounce ---
  if (now - lastButtonTime < DEBOUNCE_DELAY) {
    trackSpeakButton(now);
    return;
  }

  // --- Combos especiais (verificar ANTES dos botoes individuais) ---
  bool catUpDown  = (digitalRead(btnCatUp) == LOW && digitalRead(btnCatDown) == LOW);
  bool wordUpDown = (digitalRead(btnWordUp) == LOW && digitalRead(btnWordDown) == LOW);

  if (catUpDown && phraseCount > 0) {
    // Cat+ e Cat- juntos = falar frase completa
    vibrate();
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

  // --- Navegacao de categorias ---
  if (digitalRead(btnCatUp) == LOW) {
    catIndex = (catIndex + 1) % NUM_CATEGORIES;
    wordIndex = 0;
    vibrate();
    playNavTone(1200);
    displaySelection();
    lastButtonTime = now;
    lastActivityTime = now;
  }
  else if (digitalRead(btnCatDown) == LOW) {
    catIndex = (catIndex - 1 + NUM_CATEGORIES) % NUM_CATEGORIES;
    wordIndex = 0;
    vibrate();
    playNavTone(1000);
    displaySelection();
    lastButtonTime = now;
    lastActivityTime = now;
  }
  // --- Navegacao de palavras ---
  else if (digitalRead(btnWordUp) == LOW) {
    int n = categories[catIndex].numWords;
    wordIndex = (wordIndex + 1) % n;
    vibrate();
    playNavTone(800);
    displaySelection();
    lastButtonTime = now;
    lastActivityTime = now;
  }
  else if (digitalRead(btnWordDown) == LOW) {
    int n = categories[catIndex].numWords;
    wordIndex = (wordIndex - 1 + n) % n;
    vibrate();
    playNavTone(600);
    displaySelection();
    lastButtonTime = now;
    lastActivityTime = now;
  }

  // --- Botao FALAR (long press detection) ---
  trackSpeakButton(now);
}

// ===================== BOTAO FALAR =====================
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
      // Long press -> adiciona a frase
      addToPhrase();
    } else {
      // Short press -> fala imediatamente
      speakCurrentWord();
    }
  }
  speakBtnPrev = pressed;
}

// ===================== DISPLAY =====================
void displaySelection() {
  lcd.clear();

  // Linha 1: nome da categoria + icone bateria
  lcd.setCursor(0, 0);
  lcd.print(categories[catIndex].name);
  displayBattery();

  // Linha 2: seta + palavra + indicador de frase
  lcd.setCursor(0, 1);
  lcd.write(byte(0)); // seta
  lcd.print(' ');
  lcd.print(categories[catIndex].words[wordIndex]);

  // Indicador de frase (canto inferior direito)
  if (phraseCount > 0) {
    lcd.setCursor(14, 1);
    lcd.write(byte(5)); // coracao
    lcd.print(phraseCount);
  }

  // Monitor serial
  Serial.print(F("["));
  Serial.print(categories[catIndex].name);
  Serial.print(F("] > "));
  Serial.println(categories[catIndex].words[wordIndex]);
}

void displayBattery() {
  lcd.setCursor(15, 0);
  if (batteryPercent > 60)
    lcd.write(byte(2));      // cheio
  else if (batteryPercent > 20)
    lcd.write(byte(3));      // meio
  else
    lcd.write(byte(4));      // baixo
}

// ===================== FALAR =====================
void speakCurrentWord() {
  const char* word = categories[catIndex].words[wordIndex];
  int toneIndex = catIndex * 5 + wordIndex;

  vibrate();

  // Feedback visual
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.write(byte(1)); // icone som
  lcd.print(F(" Falando..."));
  lcd.setCursor(0, 1);
  lcd.print(word);

  // Monitor serial
  Serial.print(F(">> FALAR: \""));
  Serial.print(word);
  Serial.print(F("\" [tom: "));
  Serial.print(tones[toneIndex]);
  Serial.println(F(" Hz]"));

  // Calcula duracao baseada no volume (simula volume do DFPlayer)
  int dur = map(volume, 0, 30, 50, 300);

  // Simula audio com buzzer
  int freq = tones[toneIndex];
  tone(buzzerPin, freq, dur);
  delay(dur + 50);
  tone(buzzerPin, freq + 80, dur);
  delay(dur + 50);
  tone(buzzerPin, freq, dur * 2);
  delay(dur * 2 + 100);
  noTone(buzzerPin);

  // Volta a selecao
  displaySelection();
}

// ===================== FRASE COMPOSTA =====================
void addToPhrase() {
  if (phraseCount >= MAX_PHRASE) {
    lcd.clear();
    lcd.print(F("Frase cheia!"));
    lcd.setCursor(0, 1);
    lcd.print(F("Max "));
    lcd.print(MAX_PHRASE);
    lcd.print(F(" palavras"));
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
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(F("+ "));
  lcd.print(categories[catIndex].words[wordIndex]);
  lcd.setCursor(0, 1);
  lcd.print(F("Frase: "));
  lcd.print(phraseCount);
  lcd.print(F("/"));
  lcd.print(MAX_PHRASE);

  Serial.print(F("Frase +: "));
  Serial.print(categories[catIndex].words[wordIndex]);
  Serial.print(F(" ("));
  Serial.print(phraseCount);
  Serial.println(F(" palavras)"));

  // Tom de confirmacao
  tone(buzzerPin, 1500, 50);
  delay(80);
  tone(buzzerPin, 2000, 50);
  delay(80);
  noTone(buzzerPin);

  delay(800);
  displaySelection();
}

void speakPhrase() {
  if (phraseCount == 0) return;

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.write(byte(1));
  lcd.print(F(" Frase ("));
  lcd.print(phraseCount);
  lcd.print(F(")..."));

  Serial.print(F("Frase completa: "));

  int dur = map(volume, 0, 30, 50, 300);

  for (int i = 0; i < phraseCount; i++) {
    int c = phraseBuffer[i].cat;
    int w = phraseBuffer[i].word;
    const char* word = categories[c].words[w];
    int toneIndex = c * 5 + w;

    // Mostra palavra atual na linha 2
    lcd.setCursor(0, 1);
    lcd.print(F("                ")); // limpa linha
    lcd.setCursor(0, 1);
    lcd.print(word);

    Serial.print(word);
    if (i < phraseCount - 1) Serial.print(F(" + "));

    // Toca tom
    int freq = tones[toneIndex];
    tone(buzzerPin, freq, dur);
    delay(dur + 50);
    tone(buzzerPin, freq + 80, dur);
    delay(dur + 50);
    noTone(buzzerPin);

    if (i < phraseCount - 1) {
      delay(PHRASE_DELAY - dur * 2 - 100);
    }
  }

  Serial.println();
  delay(800);

  // Limpa frase apos falar
  phraseCount = 0;
  displaySelection();
}

void clearPhrase() {
  phraseCount = 0;
  vibrate();
  lcd.clear();
  lcd.print(F("Frase limpa"));
  Serial.println(F("Frase limpa"));

  // Tom de limpeza
  tone(buzzerPin, 800, 80);
  delay(100);
  tone(buzzerPin, 400, 80);
  delay(100);
  noTone(buzzerPin);

  delay(800);
  displaySelection();
}

// ===================== VOLUME =====================
void updateVolume() {
  int raw = analogRead(pinVolume);
  int newVol = map(raw, 0, 1023, 0, 30);
  if (abs(newVol - volume) > 1) {
    volume = newVol;
    Serial.print(F("Volume: "));
    Serial.println(volume);
  }
}

// ===================== BATERIA =====================
int readBattery() {
  // Na simulacao: potenciometro 0-1023 mapeado para 0-100%
  int raw = analogRead(pinBattery);
  int pct = map(raw, 0, 1023, 0, 100);
  return constrain(pct, 0, 100);
}

// ===================== SLEEP =====================
void enterSleep() {
  isSleeping = true;
  lcd.noBacklight();
  Serial.println(F("Sleep (2 min inatividade)"));
}

void wakeUp() {
  isSleeping = false;
  lcd.backlight();
  lastActivityTime = millis();
  lastButtonTime = millis();
  displaySelection();
  Serial.println(F("Wake up!"));
  delay(200);
}

// ===================== NAVEGACAO - TOM =====================
void playNavTone(int freq) {
  int dur = map(volume, 0, 30, 10, 50);
  tone(buzzerPin, freq, dur);
  delay(dur);
  noTone(buzzerPin);
}
