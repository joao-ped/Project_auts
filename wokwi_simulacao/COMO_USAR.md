# Como Simular o "Voz Autista v3.0" no Wokwi

> **Atalho:** abra `abrir_no_wokwi.html` no navegador deste projeto para uma pagina com
> botoes "Copiar diagram.json" / "Copiar sketch.ino" e o link direto para o Wokwi em branco.

## O que mudou da v2.0 para a v3.0 (simulacao)

| Item | v2.0 | v3.0 |
|------|------|------|
| Bateria em A1 | Potenciometro direto no pino | Pot como "fonte variavel" + **divisor real 100k/33k** + leitura com referencia interna 1.1V (identico ao hardware) |
| Vibracao em D7 | LED + resistor 220 direto | **Driver real**: D7 -> 1k -> base do 2N2222; LED como carga indicadora |
| D11 (DFPlayer RX) | Resistor 1k solto | **Divisor 1k/2k** (nivel 3.3V, igual ao hardware) |
| Labels | Minimos | Labels em portugues por bloco funcional |
| Cores dos fios | Variadas | Padronizadas: vermelho=VCC, preto=GND, amarelo (gold)=digital, verde=SDA, laranja=SCL, roxo=A0, marrom=A1 |

A **pinagem nao mudou** (D2-D6 botoes, D7 vibracao, D10/D11 DFPlayer, A0 volume,
A1 bateria, A4/A5 I2C). O hardware real v3.0 ganhou o fio **BUSY -> D8** (nao usado
na simulacao, pois o buzzer toca de forma sincrona).

## Metodo 1 - Pagina assistente (mais rapido, recomendado)

1. Abra `wokwi_simulacao/abrir_no_wokwi.html` no navegador (clique duplo)
2. Clique em **"Abrir Wokwi (Arduino Uno em branco)"** - abre nova aba
3. No Wokwi, va na aba **diagram.json**, apague tudo
4. Volte a pagina assistente e clique **"Copiar diagram.json"**, cole no Wokwi (Ctrl+V)
5. Va na aba **sketch.ino**, apague, copie do assistente, cole no Wokwi
6. Aperte **Play** verde

## Metodo 2 - Copy/paste manual

1. Acesse [https://wokwi.com](https://wokwi.com)
2. Crie uma conta (gratuita) ou faca login
3. Clique em **"New Project"** > **"Arduino Uno"**
4. No editor de codigo, substitua todo o conteudo pelo arquivo `sketch.ino`
5. Clique na aba **"diagram.json"** (parte inferior do editor)
6. Substitua todo o conteudo pelo arquivo `diagram.json`
7. Clique no botao verde **"Play"**

## Metodo 3 - Links raw do GitHub (para compartilhar com terceiros)

- `diagram.json`: https://raw.githubusercontent.com/joao-ped/Project_auts/main/wokwi_simulacao/diagram.json
- `sketch.ino`:   https://raw.githubusercontent.com/joao-ped/Project_auts/main/wokwi_simulacao/sketch.ino

## Metodo 4 - Gist + URL direta

Crie um Gist publico com os 2 arquivos e abra:
```
https://wokwi.com/projects/new/gist/<GIST_ID>
```

## Componentes da simulacao v3.0

- 1x Arduino Uno
- 1x LCD 16x2 (modo I2C)
- 5x Push Button (vermelho, amarelo, verde, azul, preto)
- 1x Buzzer (substitui DFPlayer + alto-falante - o Wokwi nao tem DFPlayer)
- 1x Transistor NPN 2N2222 + 1x Resistor 1k (base) - driver de vibracao real
- 1x LED verde + 1x Resistor 220 (carga indicadora no lugar do motor coin)
- 2x Potenciometro (volume em A0; "bateria" alimentando o divisor)
- 1x Resistor 100k + 1x Resistor 33k (divisor de tensao da bateria, em A1)
- 1x Resistor 1k + 1x Resistor 2k (divisor do RX do DFPlayer, em D11)
- 1x microSD (somente referencia visual)

> **Nota:** o diodo flyback 1N4148 do motor existe **apenas no hardware real**
> (o Wokwi nao tem o componente e o LED nao gera tensao reversa). O label no
> diagrama lembra disso.

## Conexoes principais

| De                  | Para                       | Cor      | Funcao                      |
|---------------------|----------------------------|----------|-----------------------------|
| D2..D6              | Botoes (outro lado -> GND) | amarelo  | Navegacao + FALAR           |
| D7                  | R 1k -> base 2N2222        | amarelo  | Driver de vibracao          |
| 5V -> R220 -> LED   | coletor do 2N2222          | vermelho | Carga (motor no real)       |
| Emissor 2N2222      | GND                        | preto    | Referencia                  |
| D9                  | Buzzer                     | amarelo  | Audio (so simulacao)        |
| D11                 | R 1k -> R 2k -> GND        | amarelo  | Divisor RX DFPlayer (3.3V)  |
| Pot volume SIG      | A0                         | roxo     | Volume                      |
| Pot bateria SIG     | R 100k -> A1               | marrom   | "18650" simulada            |
| A1                  | R 33k -> GND               | marrom   | Perna de baixo do divisor   |
| LCD SDA / SCL       | A4 / A5                    | verde/laranja | I2C                    |

## Como testar o medidor de bateria (v3.0)

1. Rode a simulacao e espere a tela principal
2. Gire o **pot da bateria**:
   - Wiper em ~4.2V -> icone de bateria cheia
   - Wiper em ~3.5V -> icone meio
   - Wiper em ~3.0V -> icone vazio
3. O icone atualiza a cada 10 s (BATTERY_INTERVAL)

> A leitura usa `analogReference(INTERNAL)` (1.1V). O simulador AVR do Wokwi
> suporta a referencia interna; se notar valores estranhos, confira no Serial
> Monitor os valores brutos (4.2V da bateria => ADC ~969).

## Funcionalidades (iguais desde a v2.0)

- **Cat+ / Cat-**: navega categorias | **Pal+ / Pal-**: navega palavras
- **FALAR curto**: fala a palavra | **FALAR longo (>800ms)**: adiciona a frase
- **Cat+ e Cat- juntos**: fala a frase | **Pal+ e Pal- juntos**: limpa a frase
- Sleep apos 2 min; qualquer botao acorda
- 7 categorias x 5 palavras (tons unicos no buzzer para diferenciar)

## Circuito real (hardware) vs simulacao v3.0

| Aspecto       | Simulacao (Wokwi)                  | Hardware Real v3.0                          |
|---------------|------------------------------------|---------------------------------------------|
| Audio         | Buzzer em D9, tons                 | DFPlayer Mini (D10 TX / D11 RX) + falante 2W |
| Fim do audio  | Sincrono (tone + delay)            | Pino BUSY do DFPlayer -> D8                  |
| Vibracao      | 2N2222 + LED como carga            | 2N2222 + motor coin + 1N4148 antiparalelo    |
| Bateria       | Pot -> divisor 100k/33k -> A1      | 18650 -> divisor 100k/33k + 100nF -> A1      |
| Alimentacao   | 5V ideal do simulador              | 18650 -> TP4056 -> chave -> boost MT3608     |
| Decoupling    | Nao necessario                     | 470uF + 100nF no VCC do DFPlayer             |
| SD Card       | Visual                             | microSD FAT32 com 35 MP3s                    |
| I2C LCD       | Sempre 0x27                        | Auto-detecta (0x27/0x3F/0x20/0x38)           |
| Case          | N/A                                | Impressao 3D v3.0 (cunha, botoes 2+2+1)      |

## Estrutura do cartao SD (hardware real)

Identica a v2.0 - 7 pastas `/01/../07/` com `001.mp3..005.mp3`
(ver `GUIA_IMPLEMENTACAO.md`, secao 7).

## Dica: Serial Monitor

Abra o Serial Monitor (115200 baud) para ver categoria/palavra, volume,
frases, sleep/wake e o endereco I2C detectado.
