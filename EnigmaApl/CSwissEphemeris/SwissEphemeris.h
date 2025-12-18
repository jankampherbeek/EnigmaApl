// SwissEphemeris.h
#ifndef SwissEphemeris_h
#define SwissEphemeris_h

#import "sweph.h"  // Originele Swiss Ephemeris header

// Swift-vriendelijke wrappers
const char* _Nonnull swe_version(void);
double swe_calc_ut(double tjd_ut, int ipl, int iflag, double* _Nullable xx, char* _Nullable serr);

#endif
