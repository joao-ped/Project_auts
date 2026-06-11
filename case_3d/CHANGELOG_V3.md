# CHANGELOG — Case Voz Autista v2.0 → v3.0

Redesign integrado: case + circuito + simulação + manual + viewer 3D.
Arquivos novos/alterados estão listados no fim.

---

## 1. Bugs do case v2.0 corrigidos

| # | Bug (referência ao `case_voz_autista.scad` v2.0) | Correção na v3.0 |
|---|---|---|
| 1 | **Colisão Arduino × bateria**: Arduino em (5,5) ocupando X:5–74 / Y:5–59 (linhas 68–72) e berço da 18650 centrado em (55,55) com 67 mm de comprimento (linhas 115–119) — a bateria atravessava fisicamente o footprint do Arduino | Bateria movida para **poço vertical à direita** (X:122–143, Y:24.5–92.5), com **tampa de troca no fundo** (2 clipes cantilever). Zero sobreposição (tabela na seção 5) |
| 2 | **Altura interna apertada**: base de 30 mm (linha 62) para Arduino com USB-B de 15 mm + cabos + botões de corpo 15 mm | Frente com **35 mm internos** (40 externos) e traseira em cunha até ~48 mm. Botões ficam sobre o Arduino com 2 mm de folga sobre o ponto mais alto (USB-B), que fica fora da zona de botões |
| 3 | **Furos do Arduino imprecisos**: (14,2.5), (66,7.6), (66,35.6), (15.2,50.8) (linhas 432–437) | Coordenadas **canônicas** do Uno R3: (15.24,2.54), (15.24,50.80), (66.04,7.62), (66.04,35.56) |
| 4 | **Janela do LCD plana** (tampa horizontal, linhas 497–503) | Face do LCD **inclinada 12°** (estilo console de mesa), janela 73×26 na rampa, PCB fixada por 4 bosses perpendiculares à rampa |
| 5 | **Botões em linha única** com labels pequenos (linhas 505–535) | Layout **2+2+1**: par CAT em cima, par PAL no meio, FALAR sozinho embaixo, central e maior (anel Ø24 + adaptador impresso Ø18). Anéis táteis de **1.2 mm** (eram 0.5) e pictogramas em relevo (setas, balão de fala) |
| 6 | Speaker na tampa, junto dos botões (linhas 511–513, 546–549) | Speaker no **fundo** (grade para baixo, pés de borracha afastam da mesa) — não abafa quando o aparelho é segurado pela frente e libera a face superior |

## 2. Mudanças no circuito (pinagem MANTIDA)

Nenhum pino mudou de função. Diff de circuito:

| Item | v2.0 | v3.0 | Justificativa |
|------|------|------|---------------|
| Divisor da bateria (A1) | 10k + 10k | **100k + 33k + 100nF**, leitura com `analogReference(INTERNAL)` (1.1V) | **Bug real**: com a 18650 no rail, AVcc = Vbat → leitura ratiométrica constante. Ref. interna é absoluta. Dreno cai de ~210µA p/ ~32µA. Limites novos no firmware: ADC 692 (3.0V) a 969 (4.2V) |
| RX do DFPlayer (D11) | 1k em série | **1k série + 2k → GND** | DFPlayer é lógica 3.3V; divisor entrega nível correto (datasheet DFR0299) |
| Decoupling DFPlayer | — | **470µF + 100nF** no VCC/GND do módulo | Picos de corrente no início de faixa causam reset/clique (problema notório do módulo) |
| BUSY do DFPlayer | não ligado | **BUSY → D8** (fio novo) | Frase composta espera o fim real do MP3 (antes: delay fixo 1.3s). `PHRASE_DELAY` virou pausa de 250ms pós-áudio |
| Alimentação | 18650 → TP4056 → chave → VIN/5V | 18650 → TP4056 → chave → **MT3608 (5.0V)** → rail 5V | 3.0–4.2V direto: ATmega a 16MHz fora de spec (<4.5V) e LCD HD44780 sem contraste. Único módulo adicionado (~R$5) |
| Driver do motor (D7) | 2N2222 + 1k + 1N4148 | mantido | Conferido: Ib≈4.3mA, beta forçado ≈19 p/ 80mA — saturação OK; 1N4148 antiparalelo, catodo no +5V |

Pinos livres após v3.0: D9, D12, D13, A2, A3.

## 3. Decisões de design (acessibilidade autista / AAC)

- **Anéis táteis altos (1.2 mm)** ao redor de cada botão: guiam o dedo e reduzem toques acidentais (baixa coordenação motora).
- **FALAR dominante**: central inferior, anel Ø24, adaptador impresso Ø18 sobre o cap de 12 mm — é o botão mais usado.
- **Pictogramas em relevo** (▲▼ CAT, ◀▶ PAL, balão de fala FALAR): leitura tátil + visual, sem depender de cor.
- **Canaleta de 0.6 mm** no topo de cada anel para pintura acrílica ou anel de filamento colorido (FDM mono-cor não imprime colorido).
- **LCD a 12°**: legível com o aparelho sobre a mesa ou no colo, estilo console.
- **Cantos r=10 e formas arredondadas**, superfícies pensadas p/ acabamento fosco: menos reflexo e estímulo visual.
- **Chave recuada** em moldura externa: não desliga sem querer.
- **Orelhas traseiras reforçadas** com furos Ø4: cordão de pescoço ou alça de pulso.
- **Tampa de bateria no fundo** com clipes e símbolos +/− em relevo: cuidador troca a 18650 sem abrir o case.
- **Nervuras** nas paredes longas + paredes de 2.5 mm: o case vai cair no chão (uso real por crianças).
- **USB-B, jack e micro-USB pela esquerda**: upload e recarga sem desmontar.
- **Selo "VOZ AUTISTA v3.0"** em baixo-relevo no fundo + área lisa rebaixada para etiqueta com o nome do usuário.

## 4. Medidas finais

| Medida | Valor |
|--------|-------|
| Externo (L×P) | 150 × 100 mm |
| Altura frente / traseira | 40 mm / ~47.7 mm (rampa 12° a partir de y=64) |
| Interno (L×P) | 145 × 95 mm |
| Altura interna na frente | 35 mm |
| Parede / piso / topo | 2.5 mm |
| Divisão base/tampa | z = 26.5 mm |
| Cantos | r = 10 mm |
| Furos botões / anel FALAR | Ø14 / anel Ø24 |
| Janela LCD | 73 × 26 mm (ativa 71.4 × 24.3) |
| Tampa da bateria | 22.4 × 65.4 mm, 2 clipes |
| Orelhas cordão | furo Ø4.5, tab 14×8×5 |

## 5. Validação de colisões (coordenadas absolutas, mm)

| Componente | x | y | z | Folga crítica verificada |
|---|---|---|---|---|
| Arduino Uno (c/ USB) | 6.5–75.1 | 5.5–58.9 | 3–20.5 | botões começam em z=25 ✓; USB-B (alto) fora da zona de botões ✓ |
| Bateria 18650 (poço) | 122–143 | 24.5–92.5 | 2.5–21.5 | LCD termina em x=115.5 ✓; botões terminam em x≈101 ✓ |
| TP4056 | 6.5–32.5 | 62.5–79.5 | 2.5–7 | Arduino termina em y=58.9 ✓ |
| MT3608 | 34.5–51.5 | 80.5–91.5 | 2.5–7 | motor (x45–55, y65–75) não alcança ✓ |
| Perfboard driver | 10.5–30.5 | 80–90 | 2.5–13 | TP4056 termina em y=79.5 ✓ |
| DFPlayer | 97.5–118 | 77–97.5 | 2.5–10.5 | LCD pende até z≈15 nessa região ✓ |
| Alto-falante | 77.5–117.5 (corpo) | 20.5–60.5 | 2.5–8 | Arduino até x=75.1 ✓; poço da bateria em x=119.5 ✓ (postes a 118.7) |
| Motor coin | 47.5–57.5 | 67.5–77.5 | 2.5–6.5 | sob o LCD (folga >8) ✓ |
| Potenciômetro | 138.5–147.5 | 9.5–21.5 | 15–24 | parede do poço começa em y=22 ✓ |
| Chave | 22.5–36 | 92–95 | 12–17.6 | pilar de parafuso em (70,93) ✓ |
| LCD (pendurado da rampa) | 35–115 | ~64–95 | ≥12.5 do piso interno | tudo abaixo tem ≤8 mm ✓ |
| Botões (corpo) | spots Ø13 | — | 22.5–37.5 | topo do Arduino 20.5 ✓ (2 mm) |

## 6. Impressão — como reimprimir / o que reusar

**Reusar da v2.0:** nada das peças impressas (geometria mudou toda). Parafusos M2.5/M3, pés de borracha e toda a eletrônica são reaproveitados (exceto os 2 resistores de 10k, substituídos por 100k+33k).

**Imprimir (PLA ou PETG, bico 0.4, camada 0.2, 25% giroide):**

| Peça | Arquivo | Orientação | Suporte |
|------|---------|-----------|---------|
| Base | `exportar_base.scad` | fundo na mesa | NÃO |
| Tampa | `exportar_tampa.scad` | invertida (botões na mesa) | SÓ sob a rampa do LCD (cunha de ~8 mm; pinte o suporte no fatiador) |
| Tampa bateria + knob + adaptador FALAR | `exportar_tampa_bateria.scad` | deitados | NÃO |

**Validação pendente:** o `.scad` foi verificado por análise de coordenadas (tabela acima), mas **não foi renderizado** nesta máquina (OpenSCAD não instalado). Antes de fatiar: abra no OpenSCAD, F6, e confira visualmente encaixes e a rampa do LCD. Ajuste `tolerance` (0.3) se os encaixes ficarem justos na sua impressora.

## 7. Coerência entre artefatos

Pinagem/circuito v3.0 aplicados de forma idêntica em:

- `voz_autista_maker_code.ino` — firmware real (divisor novo, ref 1.1V, BUSY/D8, fim de áudio real)
- `wokwi_simulacao/sketch.ino` + `diagram.json` — divisor real 100k/33k, driver 2N2222 real, labels PT, cores padronizadas
- `wokwi_simulacao/COMO_USAR.md` — diferenças simulação × hardware
- `manual_montagem_visual.html` — manual v3.0 com SVGs novos e badges "ATUALIZADO v3.0"
- `GUIA_IMPLEMENTACAO.md` — BOM, pinagem, esquemas ASCII e montagem no case v3.0
- `case_3d/case_voz_autista_v3.scad` (+ 3 exportadores) — case novo
- `case_3d/visualizar_circuito_3d.html` — viewer 3D interativo (Three.js) com os cabos da pinagem v3.0

Convenção de cores (todos os artefatos): vermelho=VCC, preto=GND, amarelo=digital, verde=SDA, laranja=SCL, roxo=A0, marrom=A1.
