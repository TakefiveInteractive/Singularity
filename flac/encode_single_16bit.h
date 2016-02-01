//
//  encode_single_16bit.h
//  flac
//
//  Created by Yifei Teng on 1/31/16.
//  Copyright © 2016 sbooth.org. All rights reserved.
//

#ifndef encode_single_16bit_h
#define encode_single_16bit_h

#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include "flac-src/include/FLAC/all.h"

typedef struct flacWriterState {
    size_t length;
    size_t capacity;
    size_t pointer;
    FLAC__byte *data;
    bool success;
} flacWriterState;

void flacWriterStateDes(flacWriterState * state);

flacWriterState * FLAC__encodeSingle16bit(int16_t *inputBuffer, unsigned int sample_rate, unsigned int total_samples);

#endif /* encode_single_16bit_h */
