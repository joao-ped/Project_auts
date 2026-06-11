// Arquivo auxiliar para exportar APENAS a BASE (v3.0) como STL
// Abra no OpenSCAD > F6 (Render) > File > Export as STL
//
// A base imprime na orientação em que aparece (fundo na mesa),
// SEM suporte.

include <case_voz_autista_v3.scad>

// No OpenSCAD, a última atribuição no escopo raiz prevalece.
render_base         = true;
render_lid          = false;
render_battery_door = false;
render_knob         = false;
render_falar_cap    = false;
explode = 0;
