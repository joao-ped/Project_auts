# Como Simular o "Voz Autista v2.0" no Wokwi

## Metodo 1: Importar o projeto (mais rapido)

1. Acesse [https://wokwi.com](https://wokwi.com)
2. Crie uma conta (gratuita) ou faca login
3. Clique em **"New Project"** > **"Arduino Uno"**
4. No editor de codigo, substitua todo o conteudo pelo arquivo `sketch.ino`
5. Clique na aba **"diagram.json"** (parte inferior do editor)
6. Substitua todo o conteudo pelo arquivo `diagram.json`
7. Clique no botao verde **"Play"** para iniciar a simulacao

## Metodo 2: Montar manualmente

### Componentes para adicionar:
- 1x Arduino Uno
- 1x LCD 16x2 (modo I2C)
- 5x Push Button (vermelho, amarelo, verde, azul, preto)
- 1x Buzzer (simula DFPlayer + alto-falante)
- 1x LED verde (simula motor de vibracao)
- 2x Potenciometro (volume e bateria)
- 1x Resistor 1k ohm (referencia conexao DFPlayer)

### Conexoes:
| De                | Para              | Funcao                       |
|-------------------|-------------------|------------------------------|
| Arduino D2        | Botao Vermelho    | Categoria + (avancar)        |
| Arduino D3        | Botao Amarelo     | Categoria - (voltar)         |
| Arduino D4        | Botao Verde       | Palavra + (avancar)          |
| Arduino D5        | Botao Azul        | Palavra - (voltar)           |
| Arduino D6        | Botao Preto       | FALAR (curto/longo)          |
| Outro lado botoes | Arduino GND       | Todos os 5 botoes            |
| Arduino D7        | LED verde (anodo) | Feedback vibracao            |
| LED verde (catodo)| Arduino GND       | Terra LED                    |
| Arduino D9        | Buzzer (+)        | Saida de audio               |
| Buzzer (-)        | Arduino GND       | Terra buzzer                 |
| Arduino A0        | Pot volume (SIG)  | Controle de volume           |
| Pot volume (VCC)  | Arduino 5V        | Alimentacao pot              |
| Pot volume (GND)  | Arduino GND       | Terra pot                    |
| Arduino A1        | Pot bateria (SIG) | Simulacao bateria            |
| Pot bateria (VCC) | Arduino 5V        | Alimentacao pot              |
| Pot bateria (GND) | Arduino GND       | Terra pot                    |
| Arduino A4        | LCD SDA           | Dados I2C                    |
| Arduino A5        | LCD SCL           | Clock I2C                    |
| Arduino 5V        | LCD VCC           | Alimentacao LCD              |
| Arduino GND       | LCD GND           | Terra LCD                    |
| Arduino D11       | Resistor 1k       | Ref. TX para DFPlayer        |

## Funcionalidades v2.0

### Navegacao basica
- **Botao Vermelho (Cat+)**: Avanca para a proxima categoria
- **Botao Amarelo (Cat-)**: Volta para a categoria anterior
- **Botao Verde (Pal+)**: Avanca para a proxima palavra
- **Botao Azul (Pal-)**: Volta para a palavra anterior
- **Botao Preto (FALAR)**: Pressao curta = fala palavra; pressao longa (>800ms) = adiciona a frase

### Frase composta (NOVO v2.0)
1. Navegue ate a palavra desejada
2. **Segure FALAR por mais de 800ms** para adicionar a palavra ao buffer de frase
3. Repita para ate 5 palavras
4. **Pressione Cat+ e Cat- juntos** para falar a frase inteira em sequencia
5. **Pressione Pal+ e Pal- juntos** para limpar a frase
6. O icone de coracao + numero aparece no canto inferior direito quando ha palavras na frase

### Controle de volume (NOVO v2.0)
- Gire o **potenciometro de volume** (A0) para ajustar
- Faixa: 0 (mudo) a 30 (maximo)
- No simulador, controla a duracao dos tons do buzzer

### Monitoramento de bateria (NOVO v2.0)
- O **potenciometro de bateria** (A1) simula a tensao da bateria
- Icone no canto superior direito (posicao 15,0) do LCD:
  - Bateria cheia (>60%)
  - Bateria media (20-60%)
  - Bateria baixa (<20%)

### Feedback de vibracao (NOVO v2.0)
- O **LED verde** pisca brevemente (60ms) em cada acao de botao
- No hardware real, e um motor de vibracao no pino D7

### Modo sleep (NOVO v2.0)
- Apos **2 minutos** sem pressionar nenhum botao, o LCD apaga a backlight
- Qualquer botao reativa o display

### Caracteres customizados no LCD
- Char 0: Seta de selecao
- Char 1: Icone de alto-falante (falando)
- Char 2: Bateria cheia
- Char 3: Bateria media
- Char 4: Bateria baixa
- Char 5: Coracao (indicador de frase ativa)

## 7 Categorias e 35 palavras

| #  | Categoria     | Palavras                                  |
|----|---------------|-------------------------------------------|
| 1  | Necessidades  | Eu quero, Comer, Beber, Banheiro, Dormir  |
| 2  | Sentimentos   | Feliz, Triste, Bravo, Calmo, Medo         |
| 3  | Acoes         | Brincar, Ajuda, Sair, Parar, Ir           |
| 4  | Comidas       | Agua, Suco, Leite, Pao, Fruta             |
| 5  | Lugares       | Casa, Escola, Parque, Medico, Banho        |
| 6  | Pessoas       | Mamae, Papai, Vovo, Professor, Amigo       |
| 7  | Saude         | Doi, Enjoo, Frio, Calor, Cansado          |

## Tons de simulacao (Hz)

Cada palavra tem um tom unico no buzzer para diferenciar na simulacao:

```
Necessidades: 262, 294, 330, 349, 392
Sentimentos:  440, 494, 523, 587, 659
Acoes:        698, 784, 880, 988, 1047
Comidas:      1100, 1175, 1250, 1320, 1400
Lugares:      300, 350, 400, 450, 500
Pessoas:      550, 600, 650, 700, 750
Saude:        800, 850, 900, 950, 1000
```

## Circuito real (hardware) vs simulacao

| Aspecto          | Simulacao (Wokwi)            | Hardware Real                  |
|------------------|------------------------------|--------------------------------|
| Audio            | Buzzer com tons diferentes   | DFPlayer Mini + alto-falante   |
| Pinos audio      | D9 (buzzer)                  | D10/D11 (SoftwareSerial)       |
| Vibracao         | LED verde (D7)               | Motor vibracao via transistor  |
| Volume           | Potenciometro A0 (sim)       | Potenciometro A0 (real)        |
| Bateria          | Potenciometro A1 (sim)       | Divisor tensao 10k+10k (A1)   |
| SD Card          | Nao necessario               | microSD FAT32 com MP3s         |
| Resistor 1k      | Referencia visual            | Entre D11 e DFPlayer RX       |
| I2C LCD          | Sempre 0x27                  | Auto-detecta (0x27/0x3F)      |
| Alimentacao      | Simulada                     | USB ou bateria 18650           |
| Case             | N/A                          | Impressao 3D (PLA/PETG)       |

## Preparacao do cartao SD (hardware real)

Formatar microSD em FAT32 e criar a estrutura de pastas:
```
/01/001.mp3  ->  "Eu quero"     /04/001.mp3  ->  "Agua"
/01/002.mp3  ->  "Comer"        /04/002.mp3  ->  "Suco"
/01/003.mp3  ->  "Beber"        /04/003.mp3  ->  "Leite"
/01/004.mp3  ->  "Banheiro"     /04/004.mp3  ->  "Pao"
/01/005.mp3  ->  "Dormir"       /04/005.mp3  ->  "Fruta"
/02/001.mp3  ->  "Feliz"        /05/001.mp3  ->  "Casa"
/02/002.mp3  ->  "Triste"       /05/002.mp3  ->  "Escola"
/02/003.mp3  ->  "Bravo"        /05/003.mp3  ->  "Parque"
/02/004.mp3  ->  "Calmo"        /05/004.mp3  ->  "Medico"
/02/005.mp3  ->  "Medo"         /05/005.mp3  ->  "Banho"
/03/001.mp3  ->  "Brincar"      /06/001.mp3  ->  "Mamae"
/03/002.mp3  ->  "Ajuda"        /06/002.mp3  ->  "Papai"
/03/003.mp3  ->  "Sair"         /06/003.mp3  ->  "Vovo"
/03/004.mp3  ->  "Parar"        /06/004.mp3  ->  "Professor"
/03/005.mp3  ->  "Ir"           /06/005.mp3  ->  "Amigo"
                                /07/001.mp3  ->  "Doi"
                                /07/002.mp3  ->  "Enjoo"
                                /07/003.mp3  ->  "Frio"
                                /07/004.mp3  ->  "Calor"
                                /07/005.mp3  ->  "Cansado"
```

## Dica: Serial Monitor

Abra o Serial Monitor (115200 baud) para ver:
- Categoria e palavra selecionada
- Alteracoes de volume
- Palavras adicionadas a frase
- Frase completa falada
- Eventos de sleep/wake
- Endereco I2C detectado
