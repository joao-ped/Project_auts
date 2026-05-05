# Voz Autista v2.0 - Guia de Implementacao Completo

**Comunicador Assistivo para Pessoas com Autismo**

Versao: 2.0 | Atualizado: Maio 2026

---

## Indice

1. [Visao Geral do Projeto](#1-visao-geral-do-projeto)
2. [Lista de Materiais (BOM)](#2-lista-de-materiais-bom)
3. [Tabela de Pinagem](#3-tabela-de-pinagem)
4. [Esquema de Ligacoes](#4-esquema-de-ligacoes)
5. [Circuito do Motor de Vibracao](#5-circuito-do-motor-de-vibracao)
6. [Circuito de Monitoramento de Bateria](#6-circuito-de-monitoramento-de-bateria)
7. [Estrutura do Cartao SD](#7-estrutura-do-cartao-sd)
8. [Funcionalidades v2.0](#8-funcionalidades-v20)
9. [Montagem Passo a Passo](#9-montagem-passo-a-passo)
10. [Upload do Codigo](#10-upload-do-codigo)
11. [Configuracao Facil](#11-configuracao-facil)
12. [Como Usar](#12-como-usar)
13. [Resolucao de Problemas](#13-resolucao-de-problemas)
14. [Notas Tecnicas](#14-notas-tecnicas)

---

## 1. Visao Geral do Projeto

O **Voz Autista v2.0** e um dispositivo de comunicacao assistiva projetado para pessoas com autismo que possuem dificuldade na comunicacao verbal. O usuario navega por categorias e palavras usando botoes coloridos, e o dispositivo reproduz o audio correspondente por um alto-falante.

### Novidades na v2.0

- 7 categorias com 35 palavras (antes eram 3 categorias com 15 palavras)
- Controle de volume por potenciometro analogico
- Deteccao automatica do endereco I2C do display LCD
- Monitoramento de bateria com icone no LCD
- Modo frase composta (empilhar varias palavras e falar de uma vez)
- Feedback tatil por motor de vibracao
- Modo sleep apos 2 minutos de inatividade
- Secao de configuracao facil no codigo-fonte

---

## 2. Lista de Materiais (BOM)

| Qtd | Componente | Especificacao | Funcao |
|-----|-----------|---------------|--------|
| 1 | Arduino Uno R3 | ATmega328P | Microcontrolador principal |
| 1 | LCD 16x2 com modulo I2C | Endereco auto-detectado (0x27/0x3F/0x20/0x38) | Display para navegacao |
| 1 | DFPlayer Mini MP3 | Modulo MP3 com slot microSD | Reproducao de audio |
| 1 | Alto-falante | 8 ohm, 2W, 40mm | Saida de audio |
| 1 | Botao momentaneo 12mm | **Vermelho** | Categoria + (avancar) |
| 1 | Botao momentaneo 12mm | **Amarelo** | Categoria - (voltar) |
| 1 | Botao momentaneo 12mm | **Verde** | Palavra + (avancar) |
| 1 | Botao momentaneo 12mm | **Azul** | Palavra - (voltar) |
| 1 | Botao momentaneo 12mm | **Preto** | FALAR (reproducao) |
| 1 | Resistor 1k ohm | 1/4W | D11 para DFPlayer RX (protecao serial) |
| 1 | Potenciometro 10k ohm | Linear (B10K) | Ajuste de volume |
| 1 | Motor de vibracao coin | 10mm, 3-5V | Feedback tatil |
| 1 | Transistor NPN 2N2222 | TO-92 | Driver do motor de vibracao |
| 1 | Diodo 1N4148 | Diodo de sinal | Protecao flyback do motor |
| 1 | Resistor 1k ohm | 1/4W | Base do transistor 2N2222 |
| 2 | Resistor 10k ohm | 1/4W | Divisor de tensao da bateria |
| 1 | Bateria 18650 | 3.7V recarregavel | Alimentacao portatil |
| 1 | Modulo TP4056 | Carregador Li-Ion com protecao | Carga da bateria via micro-USB |
| 1 | Chave deslizante | 2 posicoes | Liga/Desliga geral |
| 1 | Cartao microSD | FAT32, ate 32GB | Armazenamento dos audios MP3 |
| -- | Fios jumper | Macho-macho e macho-femea | Conexoes |
| 1 | Case impresso 3D | Veja pasta `/case_3d/` | Caixa do dispositivo |

**Nota sobre os botoes:** Os 5 botoes sao ligados usando os resistores pull-up internos do Arduino (INPUT_PULLUP). Cada botao conecta o pino digital ao GND quando pressionado. Nao e necessario resistor externo para os botoes.

---

## 3. Tabela de Pinagem

| Pino | Componente | Conexao | Observacao |
|------|-----------|---------|------------|
| D2 | Botao Vermelho (Cat+) | Botao para GND | INPUT_PULLUP interno |
| D3 | Botao Amarelo (Cat-) | Botao para GND | INPUT_PULLUP interno |
| D4 | Botao Verde (Pal+) | Botao para GND | INPUT_PULLUP interno |
| D5 | Botao Azul (Pal-) | Botao para GND | INPUT_PULLUP interno |
| D6 | Botao Preto (FALAR) | Botao para GND | INPUT_PULLUP interno |
| D7 | Motor vibracao | Via transistor NPN 2N2222 | Veja circuito abaixo |
| D10 | DFPlayer TX | DFPlayer TX para Arduino D10 | SoftwareSerial RX |
| D11 | DFPlayer RX | Arduino D11 para 1k ohm para DFPlayer RX | SoftwareSerial TX (com resistor) |
| A0 | Potenciometro volume | Pino central (wiper) | Range 0-1023 mapeado para 0-30 |
| A1 | Divisor tensao bateria | Juncao dos dois resistores 10k ohm | V_A1 = V_bat / 2 |
| A4 | LCD SDA | Modulo I2C do LCD | Barramento I2C dados |
| A5 | LCD SCL | Modulo I2C do LCD | Barramento I2C clock |

### Diagrama de pinos do Arduino

```
                    +-----[USB]-----+
                    |               |
               D13 -|               |- D12
               3.3V-|               |- D11 ---> 1kΩ ---> DFPlayer RX
               AREF-|               |- D10 <--- DFPlayer TX
                 A0 -|   ARDUINO    |- D9
  [POT wiper]-->A1 -|    UNO R3    |- D8
            A2 -|               |- D7  ---> 1kΩ ---> Base 2N2222
            A3 -|               |- D6  <--- Botao Preto (FALAR)
  [LCD SDA] A4 -|               |- D5  <--- Botao Azul (Pal-)
  [LCD SCL] A5 -|               |- D4  <--- Botao Verde (Pal+)
                    |               |- D3  <--- Botao Amarelo (Cat-)
                    |               |- D2  <--- Botao Vermelho (Cat+)
                 5V -|               |- GND
                GND -|               |- GND
                VIN -|               |-
                    +---------------+
```

---

## 4. Esquema de Ligacoes

### 4.1 Botoes (todos iguais)

```
Pino Dx ----+---- [Botao] ---- GND
            |
        (pull-up interno ativado por software)
```

Cada botao liga o pino ao GND quando pressionado. O Arduino detecta nivel LOW como "pressionado".

| Botao | Cor | Pino | Funcao |
|-------|-----|------|--------|
| Cat+ | Vermelho | D2 | Avanca categoria |
| Cat- | Amarelo | D3 | Volta categoria |
| Pal+ | Verde | D4 | Avanca palavra |
| Pal- | Azul | D5 | Volta palavra |
| FALAR | Preto | D6 | Reproduz audio / frase |

### 4.2 DFPlayer Mini

```
             +--------+
             | DFP    |
   D10 <---- | TX     |
   D11 -1kΩ->| RX     |
         5V -| VCC    |
        GND -| GND    |
             | SPK1 --+--- Alto-falante 8Ω 2W (+)
             | SPK2 --+--- Alto-falante 8Ω 2W (-)
             | SD slot|  <-- Cartao microSD
             +--------+
```

**Importante:** O resistor de 1k ohm entre D11 e o pino RX do DFPlayer e obrigatorio. Ele limita a corrente e protege o modulo, pois o DFPlayer opera a 3.3V na serial.

### 4.3 LCD 16x2 I2C

```
Modulo I2C (soldado atras do LCD):
  VCC → 5V do Arduino
  GND → GND do Arduino
  SDA → A4 do Arduino
  SCL → A5 do Arduino
```

### 4.4 Potenciometro de Volume

```
  5V ---- [Terminal 1]
           |
  A0 ---- [Wiper (centro)]    Potenciometro 10kΩ linear
           |
  GND --- [Terminal 3]
```

---

## 5. Circuito do Motor de Vibracao

O motor de vibracao coin consome mais corrente do que um pino do Arduino pode fornecer. Por isso, usamos um transistor NPN 2N2222 como driver.

### Esquema

```
                         +5V
                          |
                    [Motor coin 10mm]
                     (+)       (-)
                      |         |
                      +--[1N4148 catodo(+) / anodo(-)]--+
                      |         |
                      |    Collector
                      |    2N2222
                      |    Base ---- 1kΩ ---- D7 (Arduino)
                      |    Emitter
                      |         |
                     GND       GND
```

### Conexoes detalhadas

| De | Para | Observacao |
|----|------|------------|
| Arduino D7 | 1k ohm | Sinal de controle |
| 1k ohm | Base do 2N2222 | Limita corrente de base |
| 2N2222 Emitter | GND | Referencia de terra |
| 2N2222 Collector | Motor(-) | Terminal negativo do motor |
| Motor(+) | +5V | Terminal positivo do motor |
| Diodo 1N4148 anodo | Motor(-) / Collector | Protecao flyback |
| Diodo 1N4148 catodo | Motor(+) / +5V | Protecao flyback |

### Como funciona

1. Arduino coloca D7 em HIGH
2. Corrente flui pela base do 2N2222 (limitada pelo resistor 1k ohm)
3. Transistor satura, permitindo corrente pelo motor
4. Motor vibra por 60ms (configuravel no codigo)
5. Ao desligar D7, o diodo 1N4148 absorve a tensao reversa gerada pela bobina do motor (protecao flyback)

### Pinagem do 2N2222 (TO-92, visto de frente)

```
     ___
    /   \
   | 2N  |
   | 2222|
    \___/
    | | |
    E B C
```

---

## 6. Circuito de Monitoramento de Bateria

A bateria 18650 (3.7V nominal, ate 4.2V carregada) e monitorada por um divisor de tensao resistivo.

### Esquema

```
  Bateria (+) ---- [10kΩ] ---- A1 (Arduino) ---- [10kΩ] ---- GND
                                |
                          (V_A1 = V_bat / 2)
```

### Como funciona

- A tensao da bateria e dividida por 2 pelo divisor resistivo
- Arduino le o valor analogico no pino A1 (0-1023 corresponde a 0-5V)
- O codigo converte para a tensao real da bateria multiplicando por 2
- Faixas de nivel:
  - **4.2V - 3.9V** = Bateria cheia (icone cheio no LCD)
  - **3.9V - 3.7V** = Bateria media
  - **3.7V - 3.5V** = Bateria baixa
  - **< 3.5V** = Bateria critica (icone vazio)

### Circuito de alimentacao completo

```
  [Bateria 18650 3.7V]
        |         |
       (+)       (-)
        |         |
  [Modulo TP4056] |     <-- Carga via micro-USB
        |         |
  [Chave deslizante]    <-- Liga/Desliga
        |         |
      VIN       GND
    (Arduino)  (Arduino)
```

**Nota:** O modulo TP4056 com protecao (versao com chip DW01A) e recomendado. Ele protege contra sobrecarga, sobredescarga e curto-circuito.

---

## 7. Estrutura do Cartao SD

O cartao microSD deve ser formatado em **FAT32**. Os arquivos MP3 devem seguir a estrutura de pastas abaixo. Sao **7 categorias** com **5 palavras** cada, totalizando **35 arquivos MP3**.

### Estrutura de pastas e arquivos

```
microSD (FAT32)
│
├── /01/                 ← Necessidades
│   ├── 001.mp3          → "Eu quero"
│   ├── 002.mp3          → "Comer"
│   ├── 003.mp3          → "Beber"
│   ├── 004.mp3          → "Banheiro"
│   └── 005.mp3          → "Dormir"
│
├── /02/                 ← Sentimentos
│   ├── 001.mp3          → "Feliz"
│   ├── 002.mp3          → "Triste"
│   ├── 003.mp3          → "Bravo"
│   ├── 004.mp3          → "Calmo"
│   └── 005.mp3          → "Medo"
│
├── /03/                 ← Acoes
│   ├── 001.mp3          → "Brincar"
│   ├── 002.mp3          → "Ajuda"
│   ├── 003.mp3          → "Sair"
│   ├── 004.mp3          → "Parar"
│   └── 005.mp3          → "Ir"
│
├── /04/                 ← Comidas
│   ├── 001.mp3          → "Agua"
│   ├── 002.mp3          → "Suco"
│   ├── 003.mp3          → "Leite"
│   ├── 004.mp3          → "Pao"
│   └── 005.mp3          → "Fruta"
│
├── /05/                 ← Lugares
│   ├── 001.mp3          → "Casa"
│   ├── 002.mp3          → "Escola"
│   ├── 003.mp3          → "Parque"
│   ├── 004.mp3          → "Medico"
│   └── 005.mp3          → "Banho"
│
├── /06/                 ← Pessoas
│   ├── 001.mp3          → "Mamae"
│   ├── 002.mp3          → "Papai"
│   ├── 003.mp3          → "Vovo"
│   ├── 004.mp3          → "Professor"
│   └── 005.mp3          → "Amigo"
│
└── /07/                 ← Saude
    ├── 001.mp3          → "Doi"
    ├── 002.mp3          → "Enjoo"
    ├── 003.mp3          → "Frio"
    ├── 004.mp3          → "Calor"
    └── 005.mp3          → "Cansado"
```

### Dicas para os arquivos MP3

- Use voz clara, natural e em ritmo lento
- Recomendado: taxa de 44100 Hz, 128 kbps, mono
- Duracao ideal: 1 a 3 segundos por arquivo
- Ferramentas gratuitas para gerar voz: Google Translate (copiar audio), Balabolka, ou gravar a propria voz
- Os nomes das pastas devem ser exatamente `01`, `02`, ..., `07` (com dois digitos)
- Os nomes dos arquivos devem ser exatamente `001.mp3`, `002.mp3`, ..., `005.mp3` (com tres digitos)
- **Nao coloque outros arquivos** na raiz do cartao SD (o DFPlayer pode confundir a contagem)

---

## 8. Funcionalidades v2.0

### 8.1 Controle de Volume por Potenciometro

- **Pino:** A0 (terminal central/wiper do potenciometro)
- **Funcionamento:** O Arduino le o valor analogico de A0 a cada 500ms e mapeia para volume de 0 a 30
- **Ajuste em tempo real:** Gire o potenciometro para aumentar ou diminuir o volume enquanto o dispositivo esta em uso
- O volume atual e enviado ao DFPlayer via comando `dfPlayer.volume()`

### 8.2 Auto-deteccao do Endereco I2C do LCD

- O codigo escaneia automaticamente os enderecos I2C mais comuns na inicializacao
- **Enderecos escaneados:** `0x27`, `0x3F`, `0x20`, `0x38`
- Se um LCD for encontrado em qualquer desses enderecos, ele e inicializado automaticamente
- Nao e necessario alterar o codigo ao trocar o modulo LCD
- Se nenhum LCD for detectado, o dispositivo ainda funciona (apenas sem display)

### 8.3 Monitoramento de Bateria

- **Pino:** A1 (juncao do divisor de tensao 10k ohm + 10k ohm)
- **Bateria:** 18650 3.7V recarregavel
- **Carregador:** Modulo TP4056 com protecao
- **Indicacao:** Icone de bateria no canto do LCD, atualizado a cada 10 segundos
- **Calculo:** `V_bateria = analogRead(A1) * 5.0 / 1023.0 * 2.0`
- Niveis exibidos no LCD: cheio, medio, baixo, critico

### 8.4 Frase Composta

O modo frase permite empilhar ate 5 palavras para falar uma frase completa.

| Acao | Como fazer | Resultado |
|------|-----------|-----------|
| Falar palavra individual | Press **curto** no botao FALAR (preto) | Reproduz o audio da palavra selecionada |
| Adicionar palavra a frase | Press **longo** no botao FALAR (> 800ms) | Palavra e adicionada ao buffer da frase |
| Falar frase completa | Pressionar **Cat+ e Cat-** juntos (vermelho + amarelo) | Reproduz todas as palavras da frase em sequencia |
| Limpar frase | Pressionar **Pal+ e Pal-** juntos (verde + azul) | Limpa o buffer da frase |

**Exemplo de uso:**
1. Navegue ate "Eu quero" e segure FALAR (press longo) -> adicionado
2. Navegue ate "Beber" e segure FALAR (press longo) -> adicionado
3. Navegue ate "Agua" e segure FALAR (press longo) -> adicionado
4. Pressione Cat+ e Cat- juntos -> o dispositivo fala "Eu quero... Beber... Agua"

### 8.5 Feedback Tatil por Vibracao

- **Pino:** D7 (via transistor NPN 2N2222 + diodo flyback 1N4148)
- **Motor:** Coin 10mm, alimentado por 5V
- O motor vibra brevemente (60ms) a cada press de botao, confirmando a acao
- Especialmente util para usuarios que precisam de confirmacao tatil

### 8.6 Modo Sleep (Economia de Energia)

- Apos **2 minutos** (120.000ms) sem nenhuma interacao (botao pressionado), o LCD apaga automaticamente
- O dispositivo entra em modo de baixo consumo
- **Qualquer botao** pressionado acorda o dispositivo instantaneamente
- O LCD reacende e volta ao estado anterior (categoria e palavra preservadas)
- Ideal para prolongar a vida da bateria 18650

### 8.7 Configuracao Facil

O codigo-fonte possui uma secao claramente delimitada para personalizacao:

```cpp
// =============================================================
// ██  SECAO DE CONFIGURACAO - EDITE AQUI PARA PERSONALIZAR  ██
// =============================================================
```

Nessa secao voce pode:
- Alterar nomes de categorias e palavras
- Adicionar ou remover categorias (atualizar `NUM_CATEGORIES`)
- Ajustar tempos de debounce, press longo, sleep, etc.
- Alterar os pinos dos botoes

Apos editar, basta criar as pastas e MP3s correspondentes no cartao SD.

---

## 9. Montagem Passo a Passo

### Passo 1: Preparar os botoes

1. Solde fios nos terminais dos 5 botoes momentaneos
2. Conecte um terminal de cada botao ao GND do Arduino (podem compartilhar o mesmo fio GND)
3. Conecte o outro terminal de cada botao ao pino correspondente:
   - Vermelho -> D2
   - Amarelo -> D3
   - Verde -> D4
   - Azul -> D5
   - Preto -> D6

### Passo 2: Conectar o DFPlayer Mini

1. Conecte VCC do DFPlayer ao 5V do Arduino
2. Conecte GND do DFPlayer ao GND do Arduino
3. Conecte TX do DFPlayer ao pino D10 do Arduino
4. Conecte um resistor de 1k ohm entre D11 do Arduino e o pino RX do DFPlayer
5. Conecte o alto-falante nos pinos SPK1 e SPK2 do DFPlayer
6. Insira o cartao microSD (preparado conforme secao 7)

### Passo 3: Conectar o LCD I2C

1. Conecte VCC do modulo I2C ao 5V do Arduino
2. Conecte GND do modulo I2C ao GND do Arduino
3. Conecte SDA ao pino A4 do Arduino
4. Conecte SCL ao pino A5 do Arduino

### Passo 4: Montar o potenciometro de volume

1. Conecte o terminal 1 do potenciometro ao 5V
2. Conecte o terminal central (wiper) ao pino A0
3. Conecte o terminal 3 ao GND

### Passo 5: Montar o circuito do motor de vibracao

1. Conecte D7 do Arduino a um resistor de 1k ohm
2. Conecte a outra ponta do resistor a Base do transistor 2N2222
3. Conecte o Emitter do 2N2222 ao GND
4. Conecte o Collector do 2N2222 ao terminal negativo (-) do motor
5. Conecte o terminal positivo (+) do motor ao 5V
6. Solde o diodo 1N4148 em paralelo com o motor:
   - Catodo (faixa) no terminal positivo (+) / 5V
   - Anodo no terminal negativo (-) / Collector

### Passo 6: Montar o circuito de monitoramento de bateria

1. Conecte um resistor de 10k ohm entre o terminal positivo da bateria e o pino A1
2. Conecte outro resistor de 10k ohm entre o pino A1 e o GND
3. Isso cria um divisor de tensao que reduz a tensao pela metade

### Passo 7: Montar o circuito de alimentacao

1. Conecte a bateria 18650 ao modulo TP4056 (observar polaridade!)
2. Conecte a saida do TP4056 a uma chave deslizante
3. Conecte a saida da chave ao VIN e GND do Arduino
4. Verifique: a chave deve cortar a alimentacao completamente quando desligada

### Passo 8: Montar no case 3D

1. Imprima o case 3D (arquivos na pasta `/case_3d/`)
2. Posicione os botoes nos furos do painel frontal
3. Posicione o LCD na abertura do display
4. Fixe o alto-falante na area de saida de som
5. Posicione o potenciometro no painel lateral
6. Acomode o Arduino, DFPlayer, TP4056 e bateria internamente
7. Passe a chave liga/desliga para o painel lateral
8. Feche o case

---

## 10. Upload do Codigo

### Requisitos

- Arduino IDE 1.8.x ou 2.x
- Bibliotecas necessarias (instalar via Gerenciador de Bibliotecas):
  - `LiquidCrystal_I2C` (por Frank de Brabander)
  - `DFRobotDFPlayerMini` (por DFRobot)

### Procedimento

1. Abra o arquivo `voz_autista_maker_code.ino` na Arduino IDE
2. Instale as bibliotecas: **Ferramentas > Gerenciar Bibliotecas**
   - Buscar "LiquidCrystal I2C" e instalar
   - Buscar "DFRobotDFPlayerMini" e instalar
3. Selecione a placa: **Ferramentas > Placa > Arduino Uno**
4. Selecione a porta COM correta
5. Clique em **Upload** (seta para a direita)
6. Aguarde "Upload completo"

---

## 11. Configuracao Facil

Para personalizar as categorias e palavras do dispositivo, edite a secao de configuracao no arquivo `.ino`:

### Alterar palavras existentes

Localize o array `categories[]` e altere os textos:

```cpp
Category categories[] = {
  {"Necessidades", {"Eu quero", "Comer", "Beber", "Banheiro", "Dormir"}, 5},
  // ... altere os textos entre aspas
};
```

### Adicionar nova categoria

1. Adicione uma nova linha no array `categories[]`:
```cpp
  {"MinhaCategoria", {"Palavra1", "Palavra2", "Palavra3", "Palavra4", "Palavra5"}, 5},
```
2. O `NUM_CATEGORIES` e calculado automaticamente
3. Crie a pasta correspondente no cartao SD (ex: `/08/`)
4. Grave os MP3s como `001.mp3` a `005.mp3` na nova pasta

### Alterar tempos

```cpp
const unsigned long DEBOUNCE_DELAY   = 250;    // Debounce dos botoes (ms)
const unsigned long LONG_PRESS_TIME  = 800;    // Tempo para press longo (ms)
const unsigned long SLEEP_TIMEOUT    = 120000; // Tempo para dormir (ms)
const unsigned long VOLUME_INTERVAL  = 500;    // Intervalo leitura volume (ms)
const unsigned long BATTERY_INTERVAL = 10000;  // Intervalo leitura bateria (ms)
const int VIBRATE_MS = 60;                     // Duracao vibracao (ms)
const int PHRASE_DELAY = 1300;                 // Pausa entre palavras da frase (ms)
```

---

## 12. Como Usar

### Operacao basica

1. **Ligar:** Deslize a chave para a posicao ON
2. **Aguarde** a mensagem "Voz Autista v2.0" aparecer no LCD
3. **Navegar categorias:** Use o botao vermelho (Cat+) e amarelo (Cat-)
4. **Navegar palavras:** Use o botao verde (Pal+) e azul (Pal-)
5. **Falar:** Pressione brevemente o botao preto (FALAR)
6. **Volume:** Gire o potenciometro para ajustar

### Frase composta

1. Navegue ate a primeira palavra desejada
2. **Segure** o botao preto por mais de 0.8 segundos -> palavra adicionada a frase
3. Repita para ate 5 palavras
4. Pressione **vermelho + amarelo juntos** para falar a frase toda
5. Pressione **verde + azul juntos** para limpar a frase

### Modo sleep

- Apos 2 minutos sem uso, o LCD apaga automaticamente
- Pressione qualquer botao para acordar o dispositivo

### Bateria

- Observe o icone de bateria no canto do LCD
- Recarregue conectando um cabo micro-USB ao modulo TP4056
- O LED vermelho do TP4056 indica carga em andamento
- O LED azul/verde do TP4056 indica carga completa

---

## 13. Resolucao de Problemas

| Problema | Causa Provavel | Solucao |
|----------|---------------|---------|
| LCD nao liga / tela em branco | Endereco I2C nao detectado | Verifique conexoes SDA (A4) e SCL (A5). Verifique se o modulo I2C esta soldado corretamente ao LCD. Tente ajustar o potenciometro de contraste no modulo I2C. |
| LCD exibe quadrados na linha 1 | Contraste desajustado | Gire o potenciometro azul no modulo I2C ate o texto ficar legivel |
| DFPlayer nao reproduz audio | Cartao SD com formato errado | Formate o cartao como FAT32. Verifique se as pastas sao /01/, /02/ etc. e arquivos sao 001.mp3, 002.mp3 etc. |
| Sem som no alto-falante | Conexao do alto-falante solta | Verifique se o alto-falante esta conectado em SPK1 e SPK2 do DFPlayer. Verifique se o volume nao esta no minimo (gire o potenciometro). |
| Som distorcido ou fraco | Volume muito alto ou MP3 ruim | Reduza o volume pelo potenciometro. Regrave os MP3s em 128kbps mono. |
| Botao nao responde | Fio solto ou botao com defeito | Verifique a conexao do botao ao pino correto e ao GND. Teste o botao com um multimetro. |
| Motor de vibracao nao funciona | Circuito do transistor errado | Verifique a pinagem do 2N2222 (E-B-C). Verifique o resistor de 1k ohm na base. Verifique se o diodo 1N4148 esta na polaridade correta. |
| Vibracao continua sem parar | Transistor em curto ou D7 em HIGH | Troque o 2N2222. Verifique se nao ha curto entre Collector e Emitter. |
| Bateria nao carrega | Modulo TP4056 com defeito | Verifique a polaridade da bateria no TP4056. Teste com outro cabo micro-USB. Verifique se a chave esta na posicao correta. |
| Leitura de bateria incorreta | Divisor de tensao com valores errados | Verifique se os dois resistores sao de 10k ohm. Meça a tensao no pino A1 com multimetro (deve ser metade da tensao da bateria). |
| Dispositivo desliga sozinho | Bateria descarregada | Recarregue a bateria. A protecao do TP4056 corta abaixo de ~2.5V. |
| LCD apaga sozinho | Modo sleep ativado | Normal! Pressione qualquer botao para acordar. O sleep ocorre apos 2 minutos de inatividade. |
| Erro na compilacao | Bibliotecas nao instaladas | Instale LiquidCrystal_I2C e DFRobotDFPlayerMini pelo Gerenciador de Bibliotecas. |
| Upload falha | Porta COM errada ou cabo defeituoso | Selecione a porta correta em Ferramentas > Porta. Use um cabo USB com dados (nao apenas carga). |
| Palavras na ordem errada | Arquivos MP3 nomeados incorretamente | Os arquivos devem ser nomeados 001.mp3 a 005.mp3 com tres digitos. Nao use nomes descritivos. |
| Frase composta nao funciona | Press longo nao detectado | Segure o botao preto por pelo menos 0.8 segundos. O LCD mostra um indicador quando a palavra e adicionada. |
| Volume nao muda | Potenciometro desconectado | Verifique as 3 conexoes do potenciometro: 5V, A0 (wiper), GND. |
| I2C nao detecta LCD | Barramento I2C com problema | Verifique se nao ha outros dispositivos no barramento. Tente resistores pull-up externos de 4.7k ohm em SDA e SCL. |

---

## 14. Notas Tecnicas

### Consumo de corrente estimado

| Componente | Corrente tipica |
|-----------|----------------|
| Arduino Uno | ~50 mA |
| LCD 16x2 + I2C | ~20 mA (backlight ligado) |
| DFPlayer Mini (tocando) | ~40 mA |
| Alto-falante | Incluso no DFPlayer |
| Motor vibracao (ativo) | ~80 mA (breve, 60ms) |
| Botoes e resistores | < 1 mA |
| **Total (tipico)** | **~110 mA** |

### Autonomia estimada com 18650

- Bateria 18650 tipica: 2600 mAh
- Consumo medio (uso intermitente): ~80 mA
- Autonomia estimada: **~30 horas** (dependendo do uso)

### Bibliotecas utilizadas

| Biblioteca | Versao minima | Funcao |
|-----------|--------------|--------|
| Wire.h | (inclusa no Arduino) | Comunicacao I2C |
| LiquidCrystal_I2C | 1.1.2+ | Controle do LCD |
| SoftwareSerial | (inclusa no Arduino) | Comunicacao serial com DFPlayer |
| DFRobotDFPlayerMini | 1.0.5+ | Controle do modulo MP3 |

### Limitacoes conhecidas

- O LCD 16x2 exibe no maximo 16 caracteres por linha (nomes longos sao truncados)
- A frase composta suporta ate 5 palavras (configuravel via `MAX_PHRASE`)
- O DFPlayer pode levar ~200ms para iniciar a reproducao de cada faixa
- O SoftwareSerial nos pinos D10/D11 pode conflitar com outras bibliotecas que usam interrupcoes

---

**Arquivo do codigo-fonte:** `voz_autista_maker_code.ino`
**Case 3D:** pasta `case_3d/`
**Simulacao Wokwi:** pasta `wokwi_simulacao/`
