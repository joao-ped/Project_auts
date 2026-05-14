# Voz Autista v2.0 - Comunicador Assistivo

Dispositivo de comunicacao assistiva de baixo custo para pessoas com autismo que possuem dificuldade na comunicacao verbal. O usuario navega por categorias e palavras usando botoes coloridos, e o dispositivo reproduz o audio correspondente por um alto-falante.

Projeto desenvolvido com Arduino Uno, impressao 3D e componentes acessiveis.

---

## Funcionalidades

- **7 categorias com 35 palavras** - Necessidades, Sentimentos, Acoes, Comidas, Lugares, Pessoas, Saude
- **Frases compostas** - Empilhe ate 5 palavras e fale de uma vez (ex: "Eu quero" + "Beber" + "Agua")
- **Controle de volume** - Potenciometro analogico com ajuste em tempo real
- **Monitoramento de bateria** - Icone no LCD (18650 recarregavel via USB)
- **Feedback tatil** - Motor de vibracao confirma cada acao
- **Modo sleep** - LCD apaga apos 2 min de inatividade para economizar bateria
- **Auto-deteccao I2C** - Funciona com diferentes modulos LCD sem alterar codigo
- **Configuracao facil** - Secao dedicada no codigo para personalizar categorias e palavras

## Como funciona

| Botao | Cor | Funcao |
|-------|-----|--------|
| Cat+ | Vermelho | Avanca categoria |
| Cat- | Amarelo | Volta categoria |
| Pal+ | Verde | Avanca palavra |
| Pal- | Azul | Volta palavra |
| FALAR | Preto | Press curto = fala / Press longo = adiciona a frase |
| Cat+ & Cat- | Vermelho + Amarelo | Fala a frase composta |
| Pal+ & Pal- | Verde + Azul | Limpa a frase |

## Hardware

### Lista de materiais principais

| Componente | Funcao |
|-----------|--------|
| Arduino Uno R3 | Microcontrolador |
| LCD 16x2 I2C | Display de navegacao |
| DFPlayer Mini + microSD | Reproducao de audio MP3 |
| Alto-falante 8ohm 2W | Saida de som |
| 5x Botoes 12mm (coloridos) | Navegacao e fala |
| Potenciometro 10k linear | Ajuste de volume |
| Motor vibracao coin 10mm | Feedback tatil |
| Transistor 2N2222 + Diodo 1N4148 | Driver do motor |
| Bateria 18650 + Modulo TP4056 | Alimentacao portatil recarregavel |
| Chave deslizante | Liga/Desliga |
| Case impresso 3D | Caixa do dispositivo |

### Pinagem do Arduino

```
D2  -> Botao Vermelho (Cat+)     D10 <- DFPlayer TX
D3  -> Botao Amarelo  (Cat-)     D11 -> 1k -> DFPlayer RX
D4  -> Botao Verde    (Pal+)     A0  <- Potenciometro (volume)
D5  -> Botao Azul     (Pal-)     A1  <- Divisor tensao (bateria)
D6  -> Botao Preto    (FALAR)    A4  -> LCD SDA (I2C)
D7  -> Transistor -> Motor vib.  A5  -> LCD SCL (I2C)
```

### Custo estimado

O custo total dos componentes fica entre **R$ 80 - R$ 120**, dependendo do fornecedor. Componentes mais caros: Arduino (~R$35), DFPlayer (~R$15), bateria 18650 (~R$20), impressao 3D (~R$15).

## Estrutura do projeto

```
Project_auts/
|-- voz_autista_maker_code.ino    # Codigo principal (hardware real)
|-- GUIA_IMPLEMENTACAO.md         # Guia completo de montagem e uso
|-- manual_montagem_visual.html   # Manual visual com diagramas SVG interativos
|-- case_3d/
|   |-- case_voz_autista.scad     # Case 3D parametrico (OpenSCAD)
|   |-- exportar_base.scad        # Exportar apenas a base do case
|   |-- exportar_tampa.scad       # Exportar apenas a tampa do case
|   |-- visualizar_case_3d.html   # Visualizador 3D interativo no navegador
|-- wokwi_simulacao/
|   |-- sketch.ino                # Codigo adaptado para simulacao
|   |-- diagram.json              # Circuito do simulador Wokwi
|   |-- wokwi.toml                # Configuracao do Wokwi
|   |-- COMO_USAR.md              # Instrucoes da simulacao
|-- Apresentacao_Voz_Autista.pptx       # Apresentacao v1
|-- Apresentacao_Voz_Autista_v2.pptx    # Apresentacao v2
```

## Simulacao (sem hardware)

O projeto pode ser testado integralmente no simulador **Wokwi** sem precisar de nenhum componente fisico:

1. Acesse [wokwi.com](https://wokwi.com)
2. Crie um novo projeto Arduino Uno
3. Cole o conteudo de `wokwi_simulacao/sketch.ino` no editor
4. Cole o conteudo de `wokwi_simulacao/diagram.json` na aba diagram.json
5. Clique em Play

Na simulacao, o DFPlayer e substituido por um buzzer e o motor de vibracao por um LED verde.

## Cartao SD (hardware real)

Formato: **FAT32** | 7 pastas | 35 arquivos MP3 (voz clara, 1-3s cada)

```
/01/ Necessidades   001.mp3="Eu quero"  002.mp3="Comer"  003.mp3="Beber"  004.mp3="Banheiro"  005.mp3="Dormir"
/02/ Sentimentos    001.mp3="Feliz"     002.mp3="Triste" 003.mp3="Bravo"  004.mp3="Calmo"     005.mp3="Medo"
/03/ Acoes          001.mp3="Brincar"   002.mp3="Ajuda"  003.mp3="Sair"   004.mp3="Parar"     005.mp3="Ir"
/04/ Comidas        001.mp3="Agua"      002.mp3="Suco"   003.mp3="Leite"  004.mp3="Pao"       005.mp3="Fruta"
/05/ Lugares        001.mp3="Casa"      002.mp3="Escola" 003.mp3="Parque" 004.mp3="Medico"    005.mp3="Banho"
/06/ Pessoas        001.mp3="Mamae"     002.mp3="Papai"  003.mp3="Vovo"   004.mp3="Professor" 005.mp3="Amigo"
/07/ Saude          001.mp3="Doi"       002.mp3="Enjoo"  003.mp3="Frio"   004.mp3="Calor"     005.mp3="Cansado"
```

## Case 3D

O case foi projetado em **OpenSCAD** com parametros editaveis. Dimensoes: 170x110x42mm.

- Abra `case_3d/case_voz_autista.scad` no [OpenSCAD](https://openscad.org)
- Ou visualize no navegador abrindo `case_3d/visualizar_case_3d.html`
- Material recomendado: PLA ou PETG

Inclui: berco para bateria 18650, furos para botoes, janela do LCD, grade do alto-falante, abertura para USB/SD/volume/chave.

## Dependencias (Arduino IDE)

Instalar via **Ferramentas > Gerenciar Bibliotecas**:

- `LiquidCrystal_I2C` (por Frank de Brabander)
- `DFRobotDFPlayerMini` (por DFRobot)

## Autonomia

- Bateria 18650 (2600mAh tipica)
- Consumo medio: ~80mA (uso intermitente)
- Autonomia estimada: **~30 horas**

## Licenca

Projeto de codigo aberto para fins educacionais e assistivos.
