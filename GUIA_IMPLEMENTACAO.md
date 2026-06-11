# Voz Autista v3.0 - Guia de Implementacao Completo

**Comunicador Assistivo para Pessoas com Autismo**

Versao: 3.0 | Atualizado: Junho 2026

---

## Indice

1. [Visao Geral do Projeto](#1-visao-geral-do-projeto)
2. [Lista de Materiais (BOM)](#2-lista-de-materiais-bom)
3. [Tabela de Pinagem](#3-tabela-de-pinagem)
4. [Esquema de Ligacoes](#4-esquema-de-ligacoes)
5. [Circuito do Motor de Vibracao](#5-circuito-do-motor-de-vibracao)
6. [Circuito de Monitoramento de Bateria](#6-circuito-de-monitoramento-de-bateria)
7. [Estrutura do Cartao SD](#7-estrutura-do-cartao-sd)
8. [Funcionalidades](#8-funcionalidades)
9. [Montagem Passo a Passo (case v3.0)](#9-montagem-passo-a-passo-case-v30)
10. [Upload do Codigo](#10-upload-do-codigo)
11. [Configuracao Facil](#11-configuracao-facil)
12. [Como Usar](#12-como-usar)
13. [Resolucao de Problemas](#13-resolucao-de-problemas)
14. [Notas Tecnicas](#14-notas-tecnicas)

---

## 1. Visao Geral do Projeto

O **Voz Autista** e um dispositivo de comunicacao assistiva (AAC) de baixo custo
(~R$128) para pessoas autistas nao-verbais ou com comunicacao verbal limitada.
O usuario navega por 7 categorias x 5 palavras com botoes coloridos e o
dispositivo reproduz o audio MP3 correspondente.

### O que mudou da v2.0 para a v3.0

**A pinagem dos botoes, LCD, DFPlayer, volume e vibracao NAO mudou.**
As mudancas sao de circuito (valores e fios novos) e de case:

| Mudanca | Por que |
|---------|---------|
| Divisor da bateria: **10k+10k -> 100k+33k** + capacitor 100nF em A1, lido com a **referencia interna de 1.1V** | Com a 18650 alimentando o Arduino, o VCC *e* a tensao da bateria - medir Vbat/2 contra o proprio VCC dava leitura constante (bug). A referencia interna e absoluta. Bonus: o dreno cai de ~210uA para ~32uA |
| RX do DFPlayer: resistor 1k -> **divisor 1k/2k** | O DFPlayer e logica 3.3V; o divisor entrega 3.3V limpos (recomendacao do datasheet DFR0299) |
| **Capacitor 470uF + 100nF** no VCC/GND do DFPlayer | O modulo tem picos de corrente no inicio de cada faixa que causavam resets/cliques |
| **Fio novo: BUSY do DFPlayer -> D8** | A frase composta espera o MP3 terminar de verdade, em vez de pausa fixa de 1.3s |
| **Boost MT3608** entre a chave e o rail 5V | A 18650 (3.0-4.2V) direto no 5V roda o ATmega fora de spec e deixa o LCD com contraste fraco. O boost entrega 5V estaveis |
| Case v3.0 em cunha, botoes 2+2+1, bateria com tampa de troca | Ver `case_3d/CHANGELOG_V3.md` |

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
| 1 | Resistor 1k ohm | 1/4W | D11 -> RX DFPlayer (perna de cima do divisor) |
| 1 | Resistor 2k ohm | 1/4W | **v3.0** RX DFPlayer -> GND (perna de baixo) |
| 1 | Capacitor eletrolitico 470uF | >= 10V | **v3.0** VCC/GND do DFPlayer (anti-reset) |
| 2 | Capacitor ceramico 100nF | -- | **v3.0** 1x DFPlayer VCC, 1x pino A1 |
| 1 | Potenciometro 10k ohm | Linear (B10K) | Ajuste de volume |
| 1 | Motor de vibracao coin | 10mm, 3-5V | Feedback tatil |
| 1 | Transistor NPN 2N2222 | TO-92 | Driver do motor de vibracao |
| 1 | Diodo 1N4148 | Diodo de sinal | Protecao flyback do motor |
| 1 | Resistor 1k ohm | 1/4W | Base do transistor 2N2222 |
| 1 | Resistor 100k ohm | 1/4W | **v3.0** Divisor da bateria (substitui 10k) |
| 1 | Resistor 33k ohm | 1/4W | **v3.0** Divisor da bateria (substitui 10k) |
| 1 | Bateria 18650 | 3.7V recarregavel | Alimentacao portatil |
| 1 | Modulo TP4056 | Carregador Li-Ion com protecao (DW01A) | Carga via micro-USB |
| 1 | Modulo boost MT3608 | Ajustado para 5.0V | **v3.0** Rail 5V estavel a partir da 18650 |
| 1 | Chave deslizante | 2 posicoes | Liga/Desliga geral |
| 1 | Cartao microSD | FAT32, ate 32GB | Armazenamento dos audios MP3 |
| -- | Fios jumper | Macho-macho e macho-femea | Conexoes |
| 1 | Case impresso 3D v3.0 | Pasta `/case_3d/` (base + tampa + tampa bateria) | Caixa do dispositivo |

**Nota sobre os botoes:** ligados com pull-up interno (INPUT_PULLUP); cada botao
conecta o pino ao GND. Nao precisa resistor externo.

---

## 3. Tabela de Pinagem

| Pino | Componente | Conexao | Observacao |
|------|-----------|---------|------------|
| D2 | Botao Vermelho (Cat+) | Botao para GND | INPUT_PULLUP interno |
| D3 | Botao Amarelo (Cat-) | Botao para GND | INPUT_PULLUP interno |
| D4 | Botao Verde (Pal+) | Botao para GND | INPUT_PULLUP interno |
| D5 | Botao Azul (Pal-) | Botao para GND | INPUT_PULLUP interno |
| D6 | Botao Preto (FALAR) | Botao para GND | INPUT_PULLUP interno |
| D7 | Motor vibracao | Via 1k -> base 2N2222 | Flyback 1N4148 no motor |
| **D8** | **DFPlayer BUSY** | **BUSY -> D8 direto** | **NOVO v3.0** - LOW = tocando |
| D10 | DFPlayer TX | TX -> D10 | SoftwareSerial RX |
| D11 | DFPlayer RX | D11 -> 1k -> RX; RX -> 2k -> GND | **ATUALIZADO v3.0** divisor 3.3V |
| A0 | Potenciometro volume | Wiper (centro) | 0-1023 -> volume 0-30 |
| A1 | Divisor da bateria | Juncao 100k (Vbat) / 33k (GND) + 100nF | **ATUALIZADO v3.0** ref interna 1.1V |
| A4 | LCD SDA | Modulo I2C | Barramento I2C dados |
| A5 | LCD SCL | Modulo I2C | Barramento I2C clock |

Pinos livres para expansao: D9, D12, D13, A2, A3.

### Diagrama de pinos do Arduino

```
                     +-----[USB]-----+
                     |               |
                D13 -|               |- D12
                3.3V-|               |- D11 ---> 1k ---> DFPlayer RX ---> 2k ---> GND
                AREF-|               |- D10 <--- DFPlayer TX
 [POT volume]--> A0 -|    ARDUINO    |- D9
 [BAT 100k/33k]> A1 -|     UNO R3    |- D8  <--- DFPlayer BUSY        [NOVO v3.0]
                 A2 -|               |- D7  ---> 1k ---> Base 2N2222
                 A3 -|               |- D6  <--- Botao Preto  (FALAR)
   [LCD SDA] --> A4 -|               |- D5  <--- Botao Azul   (Pal-)
   [LCD SCL] --> A5 -|               |- D4  <--- Botao Verde  (Pal+)
                     |               |- D3  <--- Botao Amarelo(Cat-)
                     |               |- D2  <--- Botao Vermelho(Cat+)
                 5V -|               |- GND
                GND -|               |- GND
                VIN -|               |
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

| Botao | Cor | Pino | Posicao no case v3.0 |
|-------|-----|------|----------------------|
| CAT- | Amarelo | D3 | Fileira de cima, esquerda (simbolo "v") |
| CAT+ | Vermelho | D2 | Fileira de cima, direita (simbolo "^") |
| PAL- | Azul | D5 | Fileira do meio, esquerda (simbolo "<") |
| PAL+ | Verde | D4 | Fileira do meio, direita (simbolo ">") |
| FALAR | Preto | D6 | Embaixo, central, anel maior (balao de fala) |

### 4.2 DFPlayer Mini (ATUALIZADO v3.0)

```
                      +----------+
            D10 <---- | TX       |
 D11 --[1k]--+------> | RX       |     <- divisor 1k/2k: nivel 3.3V
             |        |          |
           [2k]       | VCC -----+--- 5V  (+ 470uF e 100nF para o GND,
             |        |          |         o mais perto possivel do modulo)
            GND       | GND -----+--- GND
                      | SPK1 ----+--- Alto-falante 8ohm 2W (+)
                      | SPK2 ----+--- Alto-falante 8ohm 2W (-)
                      | BUSY ----+--> D8   [NOVO v3.0: LOW = tocando]
                      | SD slot  |  <- microSD FAT32
                      +----------+
```

**Importante:** o eletrolitico de 470uF evita resets do DFPlayer nos picos de
corrente do inicio de cada faixa. Observe a polaridade (perna maior no VCC).

### 4.3 LCD 16x2 I2C

```
  VCC -> 5V | GND -> GND | SDA -> A4 | SCL -> A5
```

### 4.4 Potenciometro de Volume

```
  5V ---[Terminal 1]   A0 ---[Wiper]   GND ---[Terminal 3]
```

### 4.5 Alimentacao completa (ATUALIZADO v3.0)

```
  [Bateria 18650] --- B+/B- --- [TP4056 c/ protecao] --- OUT+ ---[Chave]--- IN+ [MT3608] OUT+ --- 5V do Arduino,
                                       |                                        (ajustado     LCD, DFPlayer, pot,
                                      OUT- ------------------------------------- p/ 5.0V)     motor (rail 5V comum)
                                       |
                                      GND comum (Arduino + LCD + DFPlayer + divisor + emissor 2N2222)
```

**Antes de conectar o Arduino:** alimente o MT3608 e gire o trimpot ate medir
**5.0V** na saida com multimetro. So depois ligue o rail.

**Por que o boost?** A 18650 entrega 3.0-4.2V. Direto no pino 5V, o ATmega328
roda 16MHz abaixo do minimo de 4.5V do datasheet e o LCD HD44780 perde
contraste. O MT3608 (~R$5) resolve os dois problemas e ainda da volume cheio
ao DFPlayer.

---

## 5. Circuito do Motor de Vibracao

(Sem mudancas eletricas na v3.0 - apenas documentacao revisada.)

```
            +5V ----+-------------+
                    |             |
               [Motor coin]   [1N4148]   <- catodo (faixa) no +5V
                    |             |
                    +------+------+
                           |
                       Coletor (C)
                        2N2222          Base (B) --- [1k] --- D7
                       Emissor (E)
                           |
                          GND
```

- Ib = (5 - 0.7) / 1k ~ 4.3mA -> beta forcado ~19 para 80mA: saturacao garantida
- O 1N4148 fica em **antiparalelo com o motor**: catodo (faixa) no +5V, anodo no coletor
- Pinagem do 2N2222 (TO-92, face plana para voce): **E - B - C**

---

## 6. Circuito de Monitoramento de Bateria (ATUALIZADO v3.0)

```
  Bateria (+) -----[R1 = 100k]-----+----------- A1 (Arduino)
                                   |       |
                              [R2 = 33k] [100nF]
                                   |       |
                                  GND     GND
```

### Como funciona (v3.0)

- O divisor entrega `Vbat x 33/133` em A1: 4.2V -> 1.042V; 3.0V -> 0.744V
- O codigo le A1 contra a **referencia interna de 1.1V** (`analogReference(INTERNAL)`),
  que e absoluta - nao depende do VCC variavel da bateria
- ADC ~969 = 100% | ADC ~692 = 0%
- O capacitor de 100nF em A1 compensa a impedancia alta do divisor para o
  sample-and-hold do ADC (fonte: datasheet ATmega328, secao ADC, impedancia
  de fonte recomendada <= 10k)
- Dreno permanente do divisor: ~32uA (era ~210uA com 10k+10k)

> **Atencao:** nao reutilize os resistores de 10k da v2.0 neste divisor - o
> firmware v3.0 espera 100k/33k. Se mudar os valores, recalcule os limites
> 692/969 em `readBattery()`.

---

## 7. Estrutura do Cartao SD

O cartao microSD deve ser formatado em **FAT32**. Sao **7 categorias** com
**5 palavras** cada (35 MP3s):

```
microSD (FAT32)
├── /01/ Necessidades: 001 "Eu quero", 002 "Comer", 003 "Beber", 004 "Banheiro", 005 "Dormir"
├── /02/ Sentimentos:  001 "Feliz", 002 "Triste", 003 "Bravo", 004 "Calmo", 005 "Medo"
├── /03/ Acoes:        001 "Brincar", 002 "Ajuda", 003 "Sair", 004 "Parar", 005 "Ir"
├── /04/ Comidas:      001 "Agua", 002 "Suco", 003 "Leite", 004 "Pao", 005 "Fruta"
├── /05/ Lugares:      001 "Casa", 002 "Escola", 003 "Parque", 004 "Medico", 005 "Banho"
├── /06/ Pessoas:      001 "Mamae", 002 "Papai", 003 "Vovo", 004 "Professor", 005 "Amigo"
└── /07/ Saude:        001 "Doi", 002 "Enjoo", 003 "Frio", 004 "Calor", 005 "Cansado"
```

- Pastas exatamente `01`..`07`; arquivos exatamente `001.mp3`..`005.mp3`
- 44100 Hz, 128 kbps, mono; 1-3 segundos por palavra
- Nao deixe outros arquivos na raiz do cartao

---

## 8. Funcionalidades

### 8.1 Volume por potenciometro (A0)
Leitura a cada 500ms, mapeada para 0-30 e enviada ao DFPlayer.

### 8.2 Auto-deteccao I2C do LCD
Escaneia `0x27`, `0x3F`, `0x20`, `0x38` na inicializacao.

### 8.3 Monitoramento de bateria (A1) - v3.0
Divisor 100k/33k + referencia interna 1.1V (secao 6). Icone no LCD a cada 10s.

### 8.4 Frase composta + fim de audio real (v3.0)

| Acao | Como fazer | Resultado |
|------|-----------|-----------|
| Falar palavra | Press **curto** no FALAR | Reproduz o audio |
| Adicionar a frase | Press **longo** no FALAR (>800ms) | Palavra entra no buffer (ate 5) |
| Falar frase | **Cat+ e Cat- juntos** | Fala a sequencia toda |
| Limpar frase | **Pal+ e Pal- juntos** | Esvazia o buffer |

**v3.0:** entre as palavras da frase, o firmware espera o pino **BUSY (D8)**
subir (fim real do MP3) + 250ms de pausa, em vez do delay fixo de 1.3s.
Frases soam naturais com audios de qualquer duracao.

### 8.5 Vibracao (D7)
Motor coin via 2N2222; 60ms a cada acao de botao.

### 8.6 Sleep
LCD apaga apos 2 min sem uso; qualquer botao acorda.

### 8.7 Configuracao facil
Secao demarcada no `.ino` para editar categorias, palavras e tempos.

---

## 9. Montagem Passo a Passo (case v3.0)

> Imprima primeiro: `exportar_base.scad`, `exportar_tampa.scad` e
> `exportar_tampa_bateria.scad` (que inclui o knob do potenciometro e o
> adaptador do botao FALAR). Encaixe tudo A SECO antes de soldar.

### Passo 1: Eletronica de potencia (fora do case)
1. Solde fios na 18650 (ou use suporte com fios) -> B+/B- do TP4056
2. TP4056 OUT+ -> chave deslizante -> IN+ do MT3608; OUT-/GND comum
3. Alimente e ajuste o trimpot do MT3608 ate **5.0V** na saida
4. So entao conecte OUT+ do MT3608 ao pino **5V** do Arduino

### Passo 2: Perfboard do driver e divisores
Em uma perfboard pequena (~20x10mm), monte:
1. 2N2222 + resistor 1k de base + 1N4148 (catodo p/ +5V)
2. Divisor da bateria: 100k (Vbat -> A1) + 33k (A1 -> GND) + 100nF (A1 -> GND)
3. Divisor do DFPlayer: 1k (D11 -> RX) + 2k (RX -> GND)
4. 470uF + 100nF entre VCC e GND do DFPlayer (perto do modulo)

### Passo 3: Fixar na base impressa
1. **Arduino** nos 4 pilares M2.5 (canto esquerdo; USB-B e jack saem pela esquerda)
2. **TP4056** nos clipes (parede esquerda; micro-USB pela abertura)
3. **MT3608** e **perfboard** nos cantos de retencao (fundo esquerdo/tras)
4. **DFPlayer** nos clipes (canto traseiro direito; slot SD pela parede traseira)
5. **Alto-falante** no fundo, ima para cima, borda sob os 3 postes com labio
   (o som sai pela grade no fundo do case)
6. **Motor coin** no suporte anelar (fio pela abertura lateral do anel)
7. **Chave** na moldura recuada da parede traseira (cola quente por dentro)
8. **Potenciometro** no furo da parede direita (porca por fora) + knob impresso

### Passo 4: Botoes na tampa (layout 2+2+1)
1. De cima para baixo: CAT- (amarelo) / CAT+ (vermelho), PAL- (azul) /
   PAL+ (verde), FALAR (preto) embaixo no centro
2. Cada furo tem anel tatil em relevo e canaleta para pintura/anel colorido
3. Pressione o **adaptador Ø18 impresso** sobre o cap do botao preto (FALAR)
4. **LCD**: por dentro da tampa, na face inclinada - 4 parafusos M3
   auto-atarraxantes nos bosses (janela 73x26 para a area visivel)

### Passo 5: Bateria e fechamento
1. Passe o cordao (se for usar) pelas orelhas traseiras (furos de 4mm)
2. Encaixe a tampa (saia interna sobre o rim da base, bumps de clique)
3. 2 parafusos M3: um na frente-direita, um atras-centro
4. Insira a 18650 pelo **fundo** (tampa da bateria com 2 clipes) -
   observe os simbolos +/- em relevo na propria tampa
5. Cole os 4 pes de borracha nos rebaixos do fundo

---

## 10. Upload do Codigo

- Arduino IDE 1.8.x ou 2.x
- Bibliotecas: `LiquidCrystal_I2C` (Frank de Brabander) e
  `DFRobotDFPlayerMini` (DFRobot)
- Placa: Arduino Uno; abra `voz_autista_maker_code.ino` e faca Upload
- O USB-B fica acessivel pela lateral esquerda do case - nao precisa abrir

---

## 11. Configuracao Facil

Edite a secao demarcada no `.ino` (categorias, palavras, tempos).
Detalhes na secao 11 do guia v2.0 permanecem validos; os tempos agora incluem:

```cpp
const int PHRASE_DELAY = 250;  // pausa APOS o fim real do audio (BUSY/D8)
```

---

## 12. Como Usar

1. **Ligar:** chave na posicao ON (recuada na traseira - empurre com a unha)
2. Navegue categorias (fileira de cima) e palavras (fileira do meio)
3. **FALAR** (botao grande de baixo): curto = fala; longo = adiciona a frase
4. Volume: knob estriado na lateral direita
5. Recarga: cabo micro-USB na lateral esquerda (LED vermelho = carregando,
   azul/verde = completo)
6. Troca de bateria: tampa com clipes no fundo - sem abrir o case

---

## 13. Resolucao de Problemas

| Problema | Causa Provavel | Solucao |
|----------|---------------|---------|
| LCD nao liga / tela em branco | I2C nao detectado | Verifique SDA (A4) e SCL (A5); ajuste o trimpot de contraste do backpack |
| LCD com contraste fraco mesmo ajustando | Alimentacao abaixo de 5V | Confira a saida do MT3608 (deve ser 5.0V); bateria carregada? |
| DFPlayer nao reproduz | SD em formato errado | FAT32; pastas /01/../07/; arquivos 001.mp3..005.mp3 |
| DFPlayer reseta/clica ao tocar | Falta decoupling | Confirme o 470uF + 100nF no VCC do modulo (470uF com polaridade certa) |
| Frase composta "atropela" as palavras | Fio BUSY solto | Confira BUSY -> D8 (o firmware usa timeout de 8s como fallback) |
| Medidor de bateria nao muda | Divisor errado | Confirme 100k (Vbat->A1) e 33k (A1->GND); meca A1: deve dar Vbat x 0.248 |
| Medidor de bateria sempre cheio/vazio | Resistores trocados entre si | 100k vai no lado da bateria, 33k no lado do GND |
| Volume nao muda | Pot desconectado | 3 fios: 5V, A0 (wiper), GND |
| Motor nao vibra | Driver errado | 2N2222 e E-B-C (face plana p/ voce); 1k na base; 1N4148 catodo no +5V |
| Vibracao continua | Transistor em curto | Troque o 2N2222 |
| Bateria nao carrega | TP4056/cabo | Polaridade da bateria; outro cabo micro-USB |
| Dispositivo desliga sozinho | Bateria fraca | Recarregue (protecao DW01A corta ~2.5V) |
| LCD apaga sozinho | Sleep apos 2 min | Normal - qualquer botao acorda |
| Erro de compilacao | Bibliotecas faltando | Instale LiquidCrystal_I2C e DFRobotDFPlayerMini |
| Audio engasga so na bateria | Boost no limite | Confira o ajuste de 5.0V do MT3608; bateria com carga |

---

## 14. Notas Tecnicas

### Consumo estimado (rail 5V)

| Componente | Corrente tipica |
|-----------|----------------|
| Arduino Uno | ~50 mA |
| LCD 16x2 + I2C (backlight) | ~25 mA |
| DFPlayer tocando | ~40 mA (picos de ~200 mA - dai o 470uF) |
| Motor vibracao (60ms) | ~80 mA (breve) |
| Divisor da bateria | ~0.03 mA (v3.0; era 0.21 mA) |
| **Total medio** | **~115 mA no rail 5V** |

### Autonomia com 18650 (via boost)

- O boost converte: corrente na bateria ~ 115mA x 5V / 3.7V / 0.85 (efic.) ~ 183 mA
- 18650 de 2600 mAh -> **~14h de uso continuo**; com sleep e uso intermitente,
  varios dias

### Bibliotecas

| Biblioteca | Versao minima | Funcao |
|-----------|--------------|--------|
| Wire.h | inclusa | I2C |
| LiquidCrystal_I2C | 1.1.2+ | LCD |
| SoftwareSerial | inclusa | Serial do DFPlayer (D10/D11) |
| DFRobotDFPlayerMini | 1.0.5+ | Controle do MP3 |

### Notas de projeto

- SoftwareSerial em D10/D11 usa pin-change interrupts; nao conflita com nada
  neste projeto (tone() nao e usado no firmware real)
- `analogReference(INTERNAL)` exige descartar a 1a leitura apos a troca de
  referencia (feito em `readBattery()`)
- Pinos livres para expansao: D9, D12, D13, A2, A3
- O LCD trunca nomes com mais de 16 caracteres; frase composta ate 5 palavras

---

**Codigo-fonte:** `voz_autista_maker_code.ino`
**Case 3D v3.0:** pasta `case_3d/` (ver `CHANGELOG_V3.md`)
**Simulacao Wokwi:** pasta `wokwi_simulacao/`
**Manual visual:** `manual_montagem_visual.html`
**Viewer 3D do circuito:** `case_3d/visualizar_circuito_3d.html`
