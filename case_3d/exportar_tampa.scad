// Arquivo auxiliar para exportar APENAS a TAMPA (v3.0) como STL
// Abra no OpenSCAD > F6 (Render) > File > Export as STL
//
// A tampa é exportada INVERTIDA (face dos botões na mesa) para que
// os anéis táteis, pictogramas e furos saiam limpos.
//
// ATENÇÃO - SUPORTE: como o topo é em cunha (face do LCD a 12°),
// ao imprimir invertida a aba inclinada fica suspensa (~8mm no
// ponto mais alto). Habilite suporte "touching buildplate" apenas
// nessa região (fatiador: pintar suporte sob a rampa traseira).
// O restante da peça NÃO precisa de suporte.

include <case_voz_autista_v3.scad>

render_base         = false;
render_lid          = false;
render_battery_door = false;
render_knob         = false;
render_falar_cap    = false;
explode = 0;

// Renderiza a tampa de cabeça para baixo, apoiada na face frontal plana
translate([0, 0, rear_h + 1])
mirror([0, 0, 1])
lid();
