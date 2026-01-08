//
//  SwissEphBridge.h
//  EnigmaApl
//
//  Created by Jan Kampherbeek on 20/12/2025.
//


#ifndef SwissEphBridge_h
#define SwissEphBridge_h

#include <stdint.h>

// Function declarations for Swiss Ephemeris
int32_t swe_calc_ut(double tjd_ut, int32_t ipl, int32_t iflag, double *xx, char *serr);
int32_t swe_houses(double tjd_ut, double geolat, double geolon, int32_t hsys, double *cusps, double *ascmc);
double swe_julday(int32_t year, int32_t month, int32_t day, double hour, int32_t gregflag);
void swe_revjul(double jd, int32_t gregflag, int32_t *jyear, int32_t *jmon, int32_t *jday, double *jut);
double swe_sidtime(double tjd_ut);
double swe_get_ayanamsa_ut(double tjd_ut);
const char* swe_version(char *svers);
const char* swe_get_planet_name(int32_t ipl, char *spname);
void swe_set_ephe_path(const char *path);
void swe_set_jpl_file(const char *fname);
void swe_set_topo(double geolon, double geolat, double geoalt);
void swe_set_sid_mode(int32_t sid_mode, double t0, double ayan_t0);
void swe_close(void);
void swe_azalt(double tjd_ut, int32_t calc_flag, double *geopos, double atpress, double attemp, double *xin, double *xaz);
void swe_cotrans(double *xpo, double *xpn, double eps);
int32_t swe_get_orbital_elements(double tjd_et, int32_t ipl, int32_t iflag, double *dret, char *serr);
int32_t swe_nod_aps_ut(double tjd_ut, int32_t ipl, int32_t iflag, int32_t method, double *xnasc, double *xndsc, double *xperi, double *xaphe, char *serr);

// Planet constants
#define SE_SUN          0
#define SE_MOON         1
#define SE_MERCURY      2
#define SE_VENUS        3
#define SE_MARS         4
#define SE_JUPITER      5
#define SE_SATURN       6
#define SE_URANUS       7
#define SE_NEPTUNE      8
#define SE_PLUTO        9
#define SE_EARTH        14

// Calculation flags
#define SEFLG_SWIEPH    2       /* use SWISSEPH ephemeris */
#define SEFLG_SPEED     256     /* high precision speed */

// House system constants
#define SE_HSYS_PLACIDUS     'P'
#define SE_HSYS_KOCH          'K'
#define SE_HSYS_PORPHYRIUS    'O'
#define SE_HSYS_REGIOMONTANUS 'R'
#define SE_HSYS_CAMPANUS      'C'
#define SE_HSYS_EQUAL         'E'
#define SE_HSYS_VEHLOW_EQUAL  'V'
#define SE_HSYS_WHOLE_SIGN    'W'
#define SE_HSYS_MERIDIAN      'X'
#define SE_HSYS_MORINUS       'M'
#define SE_HSYS_KRUSINSKI      'U'
#define SE_HSYS_TOPCENTRUM     'T'
#define SE_HSYS_APC            'A'
#define SE_HSYS_KRUSINSKI_PLACIDUS 'B'
#define SE_HSYS_SOLAR_FIRE     'D'
#define SE_HSYS_GALCENT_LEO    'F'
#define SE_HSYS_GALCENT_CANCER 'G'
#define SE_HSYS_AZIMUTHAL      'H'
#define SE_HSYS_POLICH_PAGE    'I'
#define SE_HSYS_ALCABITUS      'L'
#define SE_HSYS_ZARIQUEL       'Z'
#define SE_HSYS_EMPORIA        'Y'
#define SE_HSYS_ARABIC_BINDER  'J'
#define SE_HSYS_SAVARD         'S'
#define SE_HSYS_GAUDENSIUS     'N'

#endif /* SwissEphBridge_h */
