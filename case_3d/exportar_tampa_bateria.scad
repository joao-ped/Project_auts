// Arquivo auxiliar para exportar a TAMPA DA BATERIA + peças miúdas
// (knob do potenciômetro e adaptador do botão FALAR) como STL.
// Abra no OpenSCAD > F6 (Render) > File > Export as STL
//
// Todas as peças imprimem deitadas, SEM suporte:
//   - Tampa da bateria: clipes cantilever chanfrados para cima
//   - Knob Ø20 estriado: furo D-shaft 6mm para cima
//   - Adaptador FALAR Ø18: cúpula para cima
//
// Dica: imprima o knob e o adaptador com 4 perímetros (mais rígidos).

include <case_voz_autista_v3.scad>

render_base         = false;
render_lid          = false;
render_battery_door = false;
render_knob         = false;
render_falar_cap    = false;
explode = 0;

// Tampa da bateria deitada na mesa
battery_door();

// Knob ao lado
translate([40, 10, 0]) pot_knob();

// Adaptador do FALAR ao lado
translate([40, 45, 0]) falar_cap();
