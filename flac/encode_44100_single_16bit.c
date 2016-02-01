//
//  encode_44100_single_16bit.c
//  flac
//
//  Created by Yifei Teng on 1/31/16.
//  Copyright © 2016 sbooth.org. All rights reserved.
//

#include "encode_44100_single_16bit.h"
#include "flac-src/include/FLAC/all.h"
#include <stdbool.h>
#include <string.h>

#define READSIZE 1024

static void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data);

void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data)
{
    (void)encoder, (void)client_data;
}

flacWriterState * flacWriterStateCons() {
    flacWriterState * mem = (flacWriterState *) malloc(sizeof(flacWriterState));
    mem->length = 0;
    mem->capacity = 10;
    mem->pointer = 0;
    mem->data = (FLAC__byte *) malloc(10);
}

void flacWriterStateDes(flacWriterState * state) {
    if (state->data != NULL) {
        free(state->data);
    }
    state->data = NULL;
    free(state);
}

FLAC__StreamEncoderWriteStatus flac_writeCallback(const FLAC__StreamEncoder *encoder, const FLAC__byte buffer[], size_t bytes, unsigned samples, unsigned current_frame, void *client_data)
{
    flacWriterState * state = (flacWriterState *) client_data;
    // Grow buffer to accomodate input
    bool need_to_realloc = false;
    while (state->pointer + bytes > state->capacity) {
        state->capacity *= 2;
        need_to_realloc = true;
    }
    if (need_to_realloc) {
        state->data = realloc(state->data, state->capacity);
    }
    size_t i = 0, j = state->pointer;
    for (i = 0; i < bytes; i++, j++) {
        state->data[j] = buffer[i];
    }
    if (state->pointer > state->length) {
        state->length = state->pointer;
    }

    return FLAC__STREAM_ENCODER_WRITE_STATUS_OK;
}

flacWriterState * FLAC__encode44100single16bit(int16_t *inputBuffer16, unsigned int total_samples)
{
    FLAC__bool ok = true;
    FLAC__StreamEncoder *encoder = 0;
    FLAC__StreamEncoderInitStatus init_status;
    FLAC__StreamMetadata *metadata[2];
    FLAC__StreamMetadata_VorbisComment_Entry entry;
    
    static FLAC__byte buffer[READSIZE/*samples*/ * 2/*bytes_per_sample*/ * 1/*channels*/];
    static FLAC__int32 pcm[READSIZE/*samples*/ * 1/*channels*/];

    unsigned sample_rate = 0;
    unsigned channels = 0;
    unsigned bps = 0;
    
    int8_t * inputBuffer = (int8_t *) inputBuffer16;

    sample_rate = 44100;
    channels = 1;
    bps = 16;
    
    /* allocate the encoder */
    if((encoder = FLAC__stream_encoder_new()) == NULL) {
        // fprintf(stderr, "ERROR: allocating encoder\n");
        return 1;
    }
    
    ok &= FLAC__stream_encoder_set_verify(encoder, true);
    ok &= FLAC__stream_encoder_set_compression_level(encoder, 5);
    ok &= FLAC__stream_encoder_set_channels(encoder, channels);
    ok &= FLAC__stream_encoder_set_bits_per_sample(encoder, bps);
    ok &= FLAC__stream_encoder_set_sample_rate(encoder, sample_rate);
    ok &= FLAC__stream_encoder_set_total_samples_estimate(encoder, total_samples);
    
    /* now add some metadata; we'll add some tags and a padding block */
    if(ok) {
        if(
           (metadata[0] = FLAC__metadata_object_new(FLAC__METADATA_TYPE_VORBIS_COMMENT)) == NULL ||
           (metadata[1] = FLAC__metadata_object_new(FLAC__METADATA_TYPE_PADDING)) == NULL ||
           /* there are many tag (vorbiscomment) functions but these are convenient for this particular use: */
           !FLAC__metadata_object_vorbiscomment_entry_from_name_value_pair(&entry, "ARTIST", "Some Artist") ||
           !FLAC__metadata_object_vorbiscomment_append_comment(metadata[0], entry, /*copy=*/false) || /* copy=false: let metadata object take control of entry's allocated string */
           !FLAC__metadata_object_vorbiscomment_entry_from_name_value_pair(&entry, "YEAR", "1984") ||
           !FLAC__metadata_object_vorbiscomment_append_comment(metadata[0], entry, /*copy=*/false)
           ) {
            fprintf(stderr, "ERROR: out of memory or tag error\n");
            ok = false;
        }
        
        metadata[1]->length = 1234; /* set the padding length */
        
        ok = FLAC__stream_encoder_set_metadata(encoder, metadata, 2);
    }
    
    flacWriterState * outputState = NULL;
    
    /* initialize encoder */
    if(ok) {
        outputState = flacWriterStateCons();
        
        // init_status = FLAC__stream_encoder_init_file(encoder, argv[2], progress_callback, /*client_data=*/NULL);
        init_status = FLAC__stream_encoder_init_stream(encoder, flac_writeCallback, NULL, NULL, NULL, outputState);
        if(init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK) {
            fprintf(stderr, "ERROR: initializing encoder: %s\n", FLAC__StreamEncoderInitStatusString[init_status]);
            ok = false;
        }
    }
    
    size_t ptr = 0;
    
    /* read blocks of samples from WAVE file and feed to encoder */
    if(ok) {
        size_t left = (size_t)total_samples;
        while(ok && left) {
            size_t need = (left>READSIZE? (size_t)READSIZE : (size_t)left);
            
            memcpy(buffer, inputBuffer + ptr, channels * (bps/8) * need);
            ptr += channels * (bps/8) * need;
            
            if(/*fread(buffer, channels*(bps/8), need, fin) != need*/ false) {
                fprintf(stderr, "ERROR: reading from WAVE file\n");
                ok = false;
            }
            else {
                /* convert the packed little-endian 16-bit PCM samples from WAVE into an interleaved FLAC__int32 buffer for libFLAC */
                size_t i;
                for(i = 0; i < need*channels; i++) {
                    /* inefficient but simple and works on big- or little-endian machines */
                    pcm[i] = (FLAC__int32)(((FLAC__int16)(FLAC__int8)buffer[2*i+1] << 8) | (FLAC__int16)buffer[2*i]);
                }
                /* feed samples to encoder */
                ok = FLAC__stream_encoder_process_interleaved(encoder, pcm, need);
            }
            left -= need;
        }
    }
    
    ok &= FLAC__stream_encoder_finish(encoder);
    
    fprintf(stderr, "encoding: %s\n", ok? "succeeded" : "FAILED");
    fprintf(stderr, "   state: %s\n", FLAC__StreamEncoderStateString[FLAC__stream_encoder_get_state(encoder)]);
    
    /* now that encoding is finished, the metadata can be freed */
    FLAC__metadata_object_delete(metadata[0]);
    FLAC__metadata_object_delete(metadata[1]);
    
    FLAC__stream_encoder_delete(encoder);
    
    return outputState;
}