local ffi = require'ffi'

ffi.cdef[[

typedef struct FILE FILE;
typedef size_t ssize_t;
struct timeval;
struct timespec;

// /usr/include/alsa/asoundlib.h

// /usr/include/alsa/asoundef.h
enum {
	IEC958_AES0_PROFESSIONAL = (1<<0),
	IEC958_AES0_NONAUDIO = (1<<1),
	IEC958_AES0_PRO_EMPHASIS = (7<<2),
	IEC958_AES0_PRO_EMPHASIS_NOTID = (0<<2),
	IEC958_AES0_PRO_EMPHASIS_NONE = (1<<2),
	IEC958_AES0_PRO_EMPHASIS_5015 = (3<<2),
	IEC958_AES0_PRO_EMPHASIS_CCITT = (7<<2),
	IEC958_AES0_PRO_FREQ_UNLOCKED = (1<<5),
	IEC958_AES0_PRO_FS   = (3<<6),
	IEC958_AES0_PRO_FS_NOTID = (0<<6),
	IEC958_AES0_PRO_FS_44100 = (1<<6),
	IEC958_AES0_PRO_FS_48000 = (2<<6),
	IEC958_AES0_PRO_FS_32000 = (3<<6),
	IEC958_AES0_CON_NOT_COPYRIGHT = (1<<2),
	IEC958_AES0_CON_EMPHASIS = (7<<3),
	IEC958_AES0_CON_EMPHASIS_NONE = (0<<3),
	IEC958_AES0_CON_EMPHASIS_5015 = (1<<3),
	IEC958_AES0_CON_MODE = (3<<6),
	IEC958_AES1_PRO_MODE = (15<<0),
	IEC958_AES1_PRO_MODE_NOTID = (0<<0),
	IEC958_AES1_PRO_MODE_STEREOPHONIC = (2<<0),
	IEC958_AES1_PRO_MODE_SINGLE = (4<<0),
	IEC958_AES1_PRO_MODE_TWO = (8<<0),
	IEC958_AES1_PRO_MODE_PRIMARY = (12<<0),
	IEC958_AES1_PRO_MODE_BYTE3 = (15<<0),
	IEC958_AES1_PRO_USERBITS = (15<<4),
	IEC958_AES1_PRO_USERBITS_NOTID = (0<<4),
	IEC958_AES1_PRO_USERBITS_192 = (8<<4),
	IEC958_AES1_PRO_USERBITS_UDEF = (12<<4),
	IEC958_AES1_CON_CATEGORY = 0x7f,
	IEC958_AES1_CON_GENERAL = 0x00,
	IEC958_AES1_CON_LASEROPT_MASK = 0x07,
	IEC958_AES1_CON_LASEROPT_ID = 0x01,
	IEC958_AES1_CON_IEC908_CD = (IEC958_AES1_CON_LASEROPT_ID|0x00),
	IEC958_AES1_CON_NON_IEC908_CD = (IEC958_AES1_CON_LASEROPT_ID|0x08),
	IEC958_AES1_CON_MINI_DISC = (IEC958_AES1_CON_LASEROPT_ID|0x48),
	IEC958_AES1_CON_DVD  = (IEC958_AES1_CON_LASEROPT_ID|0x18),
	IEC958_AES1_CON_LASTEROPT_OTHER = (IEC958_AES1_CON_LASEROPT_ID|0x78),
	IEC958_AES1_CON_DIGDIGCONV_MASK = 0x07,
	IEC958_AES1_CON_DIGDIGCONV_ID = 0x02,
	IEC958_AES1_CON_PCM_CODER = (IEC958_AES1_CON_DIGDIGCONV_ID|0x00),
	IEC958_AES1_CON_MIXER = (IEC958_AES1_CON_DIGDIGCONV_ID|0x10),
	IEC958_AES1_CON_RATE_CONVERTER = (IEC958_AES1_CON_DIGDIGCONV_ID|0x18),
	IEC958_AES1_CON_SAMPLER = (IEC958_AES1_CON_DIGDIGCONV_ID|0x20),
	IEC958_AES1_CON_DSP  = (IEC958_AES1_CON_DIGDIGCONV_ID|0x28),
	IEC958_AES1_CON_DIGDIGCONV_OTHER = (IEC958_AES1_CON_DIGDIGCONV_ID|0x78),
	IEC958_AES1_CON_MAGNETIC_MASK = 0x07,
	IEC958_AES1_CON_MAGNETIC_ID = 0x03,
	IEC958_AES1_CON_DAT  = (IEC958_AES1_CON_MAGNETIC_ID|0x00),
	IEC958_AES1_CON_VCR  = (IEC958_AES1_CON_MAGNETIC_ID|0x08),
	IEC958_AES1_CON_DCC  = (IEC958_AES1_CON_MAGNETIC_ID|0x40),
	IEC958_AES1_CON_MAGNETIC_DISC = (IEC958_AES1_CON_MAGNETIC_ID|0x18),
	IEC958_AES1_CON_MAGNETIC_OTHER = (IEC958_AES1_CON_MAGNETIC_ID|0x78),
	IEC958_AES1_CON_BROADCAST1_MASK = 0x07,
	IEC958_AES1_CON_BROADCAST1_ID = 0x04,
	IEC958_AES1_CON_DAB_JAPAN = (IEC958_AES1_CON_BROADCAST1_ID|0x00),
	IEC958_AES1_CON_DAB_EUROPE = (IEC958_AES1_CON_BROADCAST1_ID|0x08),
	IEC958_AES1_CON_DAB_USA = (IEC958_AES1_CON_BROADCAST1_ID|0x60),
	IEC958_AES1_CON_SOFTWARE = (IEC958_AES1_CON_BROADCAST1_ID|0x40),
	IEC958_AES1_CON_IEC62105 = (IEC958_AES1_CON_BROADCAST1_ID|0x20),
	IEC958_AES1_CON_BROADCAST1_OTHER = (IEC958_AES1_CON_BROADCAST1_ID|0x78),
	IEC958_AES1_CON_BROADCAST2_MASK = 0x0f,
	IEC958_AES1_CON_BROADCAST2_ID = 0x0e,
	IEC958_AES1_CON_MUSICAL_MASK = 0x07,
	IEC958_AES1_CON_MUSICAL_ID = 0x05,
	IEC958_AES1_CON_SYNTHESIZER = (IEC958_AES1_CON_MUSICAL_ID|0x00),
	IEC958_AES1_CON_MICROPHONE = (IEC958_AES1_CON_MUSICAL_ID|0x08),
	IEC958_AES1_CON_MUSICAL_OTHER = (IEC958_AES1_CON_MUSICAL_ID|0x78),
	IEC958_AES1_CON_ADC_MASK = 0x1f,
	IEC958_AES1_CON_ADC_ID = 0x06,
	IEC958_AES1_CON_ADC  = (IEC958_AES1_CON_ADC_ID|0x00),
	IEC958_AES1_CON_ADC_OTHER = (IEC958_AES1_CON_ADC_ID|0x60),
	IEC958_AES1_CON_ADC_COPYRIGHT_MASK = 0x1f,
	IEC958_AES1_CON_ADC_COPYRIGHT_ID = 0x16,
	IEC958_AES1_CON_ADC_COPYRIGHT = (IEC958_AES1_CON_ADC_COPYRIGHT_ID|0x00),
	IEC958_AES1_CON_ADC_COPYRIGHT_OTHER = (IEC958_AES1_CON_ADC_COPYRIGHT_ID|0x60),
	IEC958_AES1_CON_SOLIDMEM_MASK = 0x0f,
	IEC958_AES1_CON_SOLIDMEM_ID = 0x08,
	IEC958_AES1_CON_SOLIDMEM_DIGITAL_RECORDER_PLAYER = (IEC958_AES1_CON_SOLIDMEM_ID|0x00),
	IEC958_AES1_CON_SOLIDMEM_OTHER = (IEC958_AES1_CON_SOLIDMEM_ID|0x70),
	IEC958_AES1_CON_EXPERIMENTAL = 0x40,
	IEC958_AES1_CON_ORIGINAL = (1<<7),
	IEC958_AES2_PRO_SBITS = (7<<0),
	IEC958_AES2_PRO_SBITS_20 = (2<<0),
	IEC958_AES2_PRO_SBITS_24 = (4<<0),
	IEC958_AES2_PRO_SBITS_UDEF = (6<<0),
	IEC958_AES2_PRO_WORDLEN = (7<<3),
	IEC958_AES2_PRO_WORDLEN_NOTID = (0<<3),
	IEC958_AES2_PRO_WORDLEN_22_18 = (2<<3),
	IEC958_AES2_PRO_WORDLEN_23_19 = (4<<3),
	IEC958_AES2_PRO_WORDLEN_24_20 = (5<<3),
	IEC958_AES2_PRO_WORDLEN_20_16 = (6<<3),
	IEC958_AES2_CON_SOURCE = (15<<0),
	IEC958_AES2_CON_SOURCE_UNSPEC = (0<<0),
	IEC958_AES2_CON_CHANNEL = (15<<4),
	IEC958_AES2_CON_CHANNEL_UNSPEC = (0<<4),
	IEC958_AES3_CON_FS   = (15<<0),
	IEC958_AES3_CON_FS_44100 = (0<<0),
	IEC958_AES3_CON_FS_NOTID = (1<<0),
	IEC958_AES3_CON_FS_48000 = (2<<0),
	IEC958_AES3_CON_FS_32000 = (3<<0),
	IEC958_AES3_CON_FS_22050 = (4<<0),
	IEC958_AES3_CON_FS_24000 = (6<<0),
	IEC958_AES3_CON_FS_88200 = (8<<0),
	IEC958_AES3_CON_FS_768000 = (9<<0),
	IEC958_AES3_CON_FS_96000 = (10<<0),
	IEC958_AES3_CON_FS_176400 = (12<<0),
	IEC958_AES3_CON_FS_192000 = (14<<0),
	IEC958_AES3_CON_CLOCK = (3<<4),
	IEC958_AES3_CON_CLOCK_1000PPM = (0<<4),
	IEC958_AES3_CON_CLOCK_50PPM = (1<<4),
	IEC958_AES3_CON_CLOCK_VARIABLE = (2<<4),
	IEC958_AES4_CON_MAX_WORDLEN_24 = (1<<0),
	IEC958_AES4_CON_WORDLEN = (7<<1),
	IEC958_AES4_CON_WORDLEN_NOTID = (0<<1),
	IEC958_AES4_CON_WORDLEN_20_16 = (1<<1),
	IEC958_AES4_CON_WORDLEN_22_18 = (2<<1),
	IEC958_AES4_CON_WORDLEN_23_19 = (4<<1),
	IEC958_AES4_CON_WORDLEN_24_20 = (5<<1),
	IEC958_AES4_CON_WORDLEN_21_17 = (6<<1),
	IEC958_AES4_CON_ORIGFS = (15<<4),
	IEC958_AES4_CON_ORIGFS_NOTID = (0<<4),
	IEC958_AES4_CON_ORIGFS_192000 = (1<<4),
	IEC958_AES4_CON_ORIGFS_12000 = (2<<4),
	IEC958_AES4_CON_ORIGFS_176400 = (3<<4),
	IEC958_AES4_CON_ORIGFS_96000 = (5<<4),
	IEC958_AES4_CON_ORIGFS_8000 = (6<<4),
	IEC958_AES4_CON_ORIGFS_88200 = (7<<4),
	IEC958_AES4_CON_ORIGFS_16000 = (8<<4),
	IEC958_AES4_CON_ORIGFS_24000 = (9<<4),
	IEC958_AES4_CON_ORIGFS_11025 = (10<<4),
	IEC958_AES4_CON_ORIGFS_22050 = (11<<4),
	IEC958_AES4_CON_ORIGFS_32000 = (12<<4),
	IEC958_AES4_CON_ORIGFS_48000 = (13<<4),
	IEC958_AES4_CON_ORIGFS_44100 = (15<<4),
	IEC958_AES5_CON_CGMSA = (3<<0),
	IEC958_AES5_CON_CGMSA_COPYFREELY = (0<<0),
	IEC958_AES5_CON_CGMSA_COPYONCE = (1<<0),
	IEC958_AES5_CON_CGMSA_COPYNOMORE = (2<<0),
	IEC958_AES5_CON_CGMSA_COPYNEVER = (3<<0),
	MIDI_CHANNELS        = 16,
	MIDI_GM_DRUM_CHANNEL = (10-1),
	MIDI_CMD_NOTE_OFF    = 0x80,
	MIDI_CMD_NOTE_ON     = 0x90,
	MIDI_CMD_NOTE_PRESSURE = 0xa0,
	MIDI_CMD_CONTROL     = 0xb0,
	MIDI_CMD_PGM_CHANGE  = 0xc0,
	MIDI_CMD_CHANNEL_PRESSURE = 0xd0,
	MIDI_CMD_BENDER      = 0xe0,
	MIDI_CMD_COMMON_SYSEX = 0xf0,
	MIDI_CMD_COMMON_MTC_QUARTER = 0xf1,
	MIDI_CMD_COMMON_SONG_POS = 0xf2,
	MIDI_CMD_COMMON_SONG_SELECT = 0xf3,
	MIDI_CMD_COMMON_TUNE_REQUEST = 0xf6,
	MIDI_CMD_COMMON_SYSEX_END = 0xf7,
	MIDI_CMD_COMMON_CLOCK = 0xf8,
	MIDI_CMD_COMMON_START = 0xfa,
	MIDI_CMD_COMMON_CONTINUE = 0xfb,
	MIDI_CMD_COMMON_STOP = 0xfc,
	MIDI_CMD_COMMON_SENSING = 0xfe,
	MIDI_CMD_COMMON_RESET = 0xff,
	MIDI_CTL_MSB_BANK    = 0x00,
	MIDI_CTL_MSB_MODWHEEL = 0x01,
	MIDI_CTL_MSB_BREATH  = 0x02,
	MIDI_CTL_MSB_FOOT    = 0x04,
	MIDI_CTL_MSB_PORTAMENTO_TIME = 0x05,
	MIDI_CTL_MSB_DATA_ENTRY = 0x06,
	MIDI_CTL_MSB_MAIN_VOLUME = 0x07,
	MIDI_CTL_MSB_BALANCE = 0x08,
	MIDI_CTL_MSB_PAN     = 0x0a,
	MIDI_CTL_MSB_EXPRESSION = 0x0b,
	MIDI_CTL_MSB_EFFECT1 = 0x0c,
	MIDI_CTL_MSB_EFFECT2 = 0x0d,
	MIDI_CTL_MSB_GENERAL_PURPOSE1 = 0x10,
	MIDI_CTL_MSB_GENERAL_PURPOSE2 = 0x11,
	MIDI_CTL_MSB_GENERAL_PURPOSE3 = 0x12,
	MIDI_CTL_MSB_GENERAL_PURPOSE4 = 0x13,
	MIDI_CTL_LSB_BANK    = 0x20,
	MIDI_CTL_LSB_MODWHEEL = 0x21,
	MIDI_CTL_LSB_BREATH  = 0x22,
	MIDI_CTL_LSB_FOOT    = 0x24,
	MIDI_CTL_LSB_PORTAMENTO_TIME = 0x25,
	MIDI_CTL_LSB_DATA_ENTRY = 0x26,
	MIDI_CTL_LSB_MAIN_VOLUME = 0x27,
	MIDI_CTL_LSB_BALANCE = 0x28,
	MIDI_CTL_LSB_PAN     = 0x2a,
	MIDI_CTL_LSB_EXPRESSION = 0x2b,
	MIDI_CTL_LSB_EFFECT1 = 0x2c,
	MIDI_CTL_LSB_EFFECT2 = 0x2d,
	MIDI_CTL_LSB_GENERAL_PURPOSE1 = 0x30,
	MIDI_CTL_LSB_GENERAL_PURPOSE2 = 0x31,
	MIDI_CTL_LSB_GENERAL_PURPOSE3 = 0x32,
	MIDI_CTL_LSB_GENERAL_PURPOSE4 = 0x33,
	MIDI_CTL_SUSTAIN     = 0x40,
	MIDI_CTL_PORTAMENTO  = 0x41,
	MIDI_CTL_SOSTENUTO   = 0x42,
	MIDI_CTL_SUSTENUTO   = 0x42,
	MIDI_CTL_SOFT_PEDAL  = 0x43,
	MIDI_CTL_LEGATO_FOOTSWITCH = 0x44,
	MIDI_CTL_HOLD2       = 0x45,
	MIDI_CTL_SC1_SOUND_VARIATION = 0x46,
	MIDI_CTL_SC2_TIMBRE  = 0x47,
	MIDI_CTL_SC3_RELEASE_TIME = 0x48,
	MIDI_CTL_SC4_ATTACK_TIME = 0x49,
	MIDI_CTL_SC5_BRIGHTNESS = 0x4a,
	MIDI_CTL_SC6         = 0x4b,
	MIDI_CTL_SC7         = 0x4c,
	MIDI_CTL_SC8         = 0x4d,
	MIDI_CTL_SC9         = 0x4e,
	MIDI_CTL_SC10        = 0x4f,
	MIDI_CTL_GENERAL_PURPOSE5 = 0x50,
	MIDI_CTL_GENERAL_PURPOSE6 = 0x51,
	MIDI_CTL_GENERAL_PURPOSE7 = 0x52,
	MIDI_CTL_GENERAL_PURPOSE8 = 0x53,
	MIDI_CTL_PORTAMENTO_CONTROL = 0x54,
	MIDI_CTL_E1_REVERB_DEPTH = 0x5b,
	MIDI_CTL_E2_TREMOLO_DEPTH = 0x5c,
	MIDI_CTL_E3_CHORUS_DEPTH = 0x5d,
	MIDI_CTL_E4_DETUNE_DEPTH = 0x5e,
	MIDI_CTL_E5_PHASER_DEPTH = 0x5f,
	MIDI_CTL_DATA_INCREMENT = 0x60,
	MIDI_CTL_DATA_DECREMENT = 0x61,
	MIDI_CTL_NONREG_PARM_NUM_LSB = 0x62,
	MIDI_CTL_NONREG_PARM_NUM_MSB = 0x63,
	MIDI_CTL_REGIST_PARM_NUM_LSB = 0x64,
	MIDI_CTL_REGIST_PARM_NUM_MSB = 0x65,
	MIDI_CTL_ALL_SOUNDS_OFF = 0x78,
	MIDI_CTL_RESET_CONTROLLERS = 0x79,
	MIDI_CTL_LOCAL_CONTROL_SWITCH = 0x7a,
	MIDI_CTL_ALL_NOTES_OFF = 0x7b,
	MIDI_CTL_OMNI_OFF    = 0x7c,
	MIDI_CTL_OMNI_ON     = 0x7d,
	MIDI_CTL_MONO1       = 0x7e,
	MIDI_CTL_MONO2       = 0x7f,
};

// /usr/include/alsa/version.h
enum {
	SND_LIB_MAJOR        = 1,
	SND_LIB_MINOR        = 0,
	SND_LIB_SUBMINOR     = 22,
	SND_LIB_EXTRAVER     = 1000000,
	SND_LIB_VERSION      = ((SND_LIB_MAJOR<<16)| (SND_LIB_MINOR<<8)| SND_LIB_SUBMINOR),
};

// /usr/include/alsa/global.h
const char *snd_asoundlib_version(void);
struct snd_dlsym_link {
 struct snd_dlsym_link *next;
 const char *dlsym_name;
 const void *dlsym_ptr;
};
extern struct snd_dlsym_link *snd_dlsym_start;
void *snd_dlopen(const char *file, int mode);
void *snd_dlsym(void *handle, const char *name, const char *version);
int snd_dlclose(void *handle);
typedef struct _snd_async_handler snd_async_handler_t;
typedef void (*snd_async_callback_t)(snd_async_handler_t *handler);
int snd_async_add_handler(snd_async_handler_t **handler, int fd,
     snd_async_callback_t callback, void *private_data);
int snd_async_del_handler(snd_async_handler_t *handler);
int snd_async_handler_get_fd(snd_async_handler_t *handler);
int snd_async_handler_get_signo(snd_async_handler_t *handler);
void *snd_async_handler_get_callback_private(snd_async_handler_t *handler);
struct snd_shm_area *snd_shm_area_create(int shmid, void *ptr);
struct snd_shm_area *snd_shm_area_share(struct snd_shm_area *area);
int snd_shm_area_destroy(struct snd_shm_area *area);
int snd_user_file(const char *file, char **result);
typedef struct timeval snd_timestamp_t;
typedef struct timespec snd_htimestamp_t;

// /usr/include/alsa/input.h
typedef struct _snd_input snd_input_t;
typedef enum _snd_input_type {
 SND_INPUT_STDIO,
 SND_INPUT_BUFFER
} snd_input_type_t;
int snd_input_stdio_open(snd_input_t **inputp, const char *file, const char *mode);
int snd_input_stdio_attach(snd_input_t **inputp, FILE *fp, int _close);
int snd_input_buffer_open(snd_input_t **inputp, const char *buffer, ssize_t size);
int snd_input_close(snd_input_t *input);
int snd_input_scanf(snd_input_t *input, const char *format, ...);
char *snd_input_gets(snd_input_t *input, char *str, size_t size);
int snd_input_getc(snd_input_t *input);
int snd_input_ungetc(snd_input_t *input, int c);

// /usr/include/alsa/output.h
typedef struct _snd_output snd_output_t;
typedef enum _snd_output_type {
 SND_OUTPUT_STDIO,
 SND_OUTPUT_BUFFER
} snd_output_type_t;
int snd_output_stdio_open(snd_output_t **outputp, const char *file, const char *mode);
int snd_output_stdio_attach(snd_output_t **outputp, FILE *fp, int _close);
int snd_output_buffer_open(snd_output_t **outputp);
size_t snd_output_buffer_string(snd_output_t *output, char **buf);
int snd_output_close(snd_output_t *output);
int snd_output_printf(snd_output_t *output, const char *format, ...)
 __attribute__ ((format (printf, 2, 3)))
 ;
int snd_output_vprintf(snd_output_t *output, const char *format, va_list args);
int snd_output_puts(snd_output_t *output, const char *str);
int snd_output_putc(snd_output_t *output, int c);
int snd_output_flush(snd_output_t *output);

// /usr/include/alsa/error.h
enum {
	SND_ERROR_BEGIN      = 500000,
	SND_ERROR_INCOMPATIBLE_VERSION = (SND_ERROR_BEGIN+0),
	SND_ERROR_ALISP_NIL  = (SND_ERROR_BEGIN+1),
};
const char *snd_strerror(int errnum);
typedef void (*snd_lib_error_handler_t)(const char *file, int line, const char *function, int err, const char *fmt, ...) ;
extern snd_lib_error_handler_t snd_lib_error;
extern int snd_lib_error_set_handler(snd_lib_error_handler_t handler);

// /usr/include/alsa/conf.h
typedef enum _snd_config_type {
        SND_CONFIG_TYPE_INTEGER,
        SND_CONFIG_TYPE_INTEGER64,
        SND_CONFIG_TYPE_REAL,
        SND_CONFIG_TYPE_STRING,
        SND_CONFIG_TYPE_POINTER,
 SND_CONFIG_TYPE_COMPOUND = 1024
} snd_config_type_t;
typedef struct _snd_config snd_config_t;
typedef struct _snd_config_iterator *snd_config_iterator_t;
typedef struct _snd_config_update snd_config_update_t;
extern snd_config_t *snd_config;
int snd_config_top(snd_config_t **config);
int snd_config_load(snd_config_t *config, snd_input_t *in);
int snd_config_load_override(snd_config_t *config, snd_input_t *in);
int snd_config_save(snd_config_t *config, snd_output_t *out);
int snd_config_update(void);
int snd_config_update_r(snd_config_t **top, snd_config_update_t **update, const char *path);
int snd_config_update_free(snd_config_update_t *update);
int snd_config_update_free_global(void);
int snd_config_search(snd_config_t *config, const char *key,
        snd_config_t **result);
int snd_config_searchv(snd_config_t *config,
         snd_config_t **result, ...);
int snd_config_search_definition(snd_config_t *config,
     const char *base, const char *key,
     snd_config_t **result);
int snd_config_expand(snd_config_t *config, snd_config_t *root,
        const char *args, snd_config_t *private_data,
        snd_config_t **result);
int snd_config_evaluate(snd_config_t *config, snd_config_t *root,
   snd_config_t *private_data, snd_config_t **result);
int snd_config_add(snd_config_t *config, snd_config_t *leaf);
int snd_config_delete(snd_config_t *config);
int snd_config_delete_compound_members(const snd_config_t *config);
int snd_config_copy(snd_config_t **dst, snd_config_t *src);
int snd_config_make(snd_config_t **config, const char *key,
      snd_config_type_t type);
int snd_config_make_integer(snd_config_t **config, const char *key);
int snd_config_make_integer64(snd_config_t **config, const char *key);
int snd_config_make_real(snd_config_t **config, const char *key);
int snd_config_make_string(snd_config_t **config, const char *key);
int snd_config_make_pointer(snd_config_t **config, const char *key);
int snd_config_make_compound(snd_config_t **config, const char *key, int join);
int snd_config_imake_integer(snd_config_t **config, const char *key, const long value);
int snd_config_imake_integer64(snd_config_t **config, const char *key, const long long value);
int snd_config_imake_real(snd_config_t **config, const char *key, const double value);
int snd_config_imake_string(snd_config_t **config, const char *key, const char *ascii);
int snd_config_imake_pointer(snd_config_t **config, const char *key, const void *ptr);
snd_config_type_t snd_config_get_type(const snd_config_t *config);
int snd_config_set_id(snd_config_t *config, const char *id);
int snd_config_set_integer(snd_config_t *config, long value);
int snd_config_set_integer64(snd_config_t *config, long long value);
int snd_config_set_real(snd_config_t *config, double value);
int snd_config_set_string(snd_config_t *config, const char *value);
int snd_config_set_ascii(snd_config_t *config, const char *ascii);
int snd_config_set_pointer(snd_config_t *config, const void *ptr);
int snd_config_get_id(const snd_config_t *config, const char **value);
int snd_config_get_integer(const snd_config_t *config, long *value);
int snd_config_get_integer64(const snd_config_t *config, long long *value);
int snd_config_get_real(const snd_config_t *config, double *value);
int snd_config_get_ireal(const snd_config_t *config, double *value);
int snd_config_get_string(const snd_config_t *config, const char **value);
int snd_config_get_ascii(const snd_config_t *config, char **value);
int snd_config_get_pointer(const snd_config_t *config, const void **value);
int snd_config_test_id(const snd_config_t *config, const char *id);
snd_config_iterator_t snd_config_iterator_first(const snd_config_t *node);
snd_config_iterator_t snd_config_iterator_next(const snd_config_iterator_t iterator);
snd_config_iterator_t snd_config_iterator_end(const snd_config_t *node);
snd_config_t *snd_config_iterator_entry(const snd_config_iterator_t iterator);
int snd_config_get_bool_ascii(const char *ascii);
int snd_config_get_bool(const snd_config_t *conf);
int snd_config_get_ctl_iface_ascii(const char *ascii);
int snd_config_get_ctl_iface(const snd_config_t *conf);
typedef struct snd_devname snd_devname_t;
struct snd_devname {
 char *name;
 char *comment;
 snd_devname_t *next;
};
int snd_names_list(const char *iface, snd_devname_t **list);
void snd_names_list_free(snd_devname_t *list);

// /usr/include/alsa/pcm.h
typedef struct _snd_pcm_info snd_pcm_info_t;
typedef struct _snd_pcm_hw_params snd_pcm_hw_params_t;
typedef struct _snd_pcm_sw_params snd_pcm_sw_params_t;
typedef struct _snd_pcm_status snd_pcm_status_t;
typedef struct _snd_pcm_access_mask snd_pcm_access_mask_t;
typedef struct _snd_pcm_format_mask snd_pcm_format_mask_t;
typedef struct _snd_pcm_subformat_mask snd_pcm_subformat_mask_t;
typedef enum _snd_pcm_class {
 SND_PCM_CLASS_GENERIC = 0,
 SND_PCM_CLASS_MULTI,
 SND_PCM_CLASS_MODEM,
 SND_PCM_CLASS_DIGITIZER,
 SND_PCM_CLASS_LAST = SND_PCM_CLASS_DIGITIZER
} snd_pcm_class_t;
typedef enum _snd_pcm_subclass {
 SND_PCM_SUBCLASS_GENERIC_MIX = 0,
 SND_PCM_SUBCLASS_MULTI_MIX,
 SND_PCM_SUBCLASS_LAST = SND_PCM_SUBCLASS_MULTI_MIX
} snd_pcm_subclass_t;
typedef enum _snd_pcm_stream {
 SND_PCM_STREAM_PLAYBACK = 0,
 SND_PCM_STREAM_CAPTURE,
 SND_PCM_STREAM_LAST = SND_PCM_STREAM_CAPTURE
} snd_pcm_stream_t;
typedef enum _snd_pcm_access {
 SND_PCM_ACCESS_MMAP_INTERLEAVED = 0,
 SND_PCM_ACCESS_MMAP_NONINTERLEAVED,
 SND_PCM_ACCESS_MMAP_COMPLEX,
 SND_PCM_ACCESS_RW_INTERLEAVED,
 SND_PCM_ACCESS_RW_NONINTERLEAVED,
 SND_PCM_ACCESS_LAST = SND_PCM_ACCESS_RW_NONINTERLEAVED
} snd_pcm_access_t;
typedef enum _snd_pcm_format {
 SND_PCM_FORMAT_UNKNOWN = -1,
 SND_PCM_FORMAT_S8 = 0,
 SND_PCM_FORMAT_U8,
 SND_PCM_FORMAT_S16_LE,
 SND_PCM_FORMAT_S16_BE,
 SND_PCM_FORMAT_U16_LE,
 SND_PCM_FORMAT_U16_BE,
 SND_PCM_FORMAT_S24_LE,
 SND_PCM_FORMAT_S24_BE,
 SND_PCM_FORMAT_U24_LE,
 SND_PCM_FORMAT_U24_BE,
 SND_PCM_FORMAT_S32_LE,
 SND_PCM_FORMAT_S32_BE,
 SND_PCM_FORMAT_U32_LE,
 SND_PCM_FORMAT_U32_BE,
 SND_PCM_FORMAT_FLOAT_LE,
 SND_PCM_FORMAT_FLOAT_BE,
 SND_PCM_FORMAT_FLOAT64_LE,
 SND_PCM_FORMAT_FLOAT64_BE,
 SND_PCM_FORMAT_IEC958_SUBFRAME_LE,
 SND_PCM_FORMAT_IEC958_SUBFRAME_BE,
 SND_PCM_FORMAT_MU_LAW,
 SND_PCM_FORMAT_A_LAW,
 SND_PCM_FORMAT_IMA_ADPCM,
 SND_PCM_FORMAT_MPEG,
 SND_PCM_FORMAT_GSM,
 SND_PCM_FORMAT_SPECIAL = 31,
 SND_PCM_FORMAT_S24_3LE = 32,
 SND_PCM_FORMAT_S24_3BE,
 SND_PCM_FORMAT_U24_3LE,
 SND_PCM_FORMAT_U24_3BE,
 SND_PCM_FORMAT_S20_3LE,
 SND_PCM_FORMAT_S20_3BE,
 SND_PCM_FORMAT_U20_3LE,
 SND_PCM_FORMAT_U20_3BE,
 SND_PCM_FORMAT_S18_3LE,
 SND_PCM_FORMAT_S18_3BE,
 SND_PCM_FORMAT_U18_3LE,
 SND_PCM_FORMAT_U18_3BE,
 SND_PCM_FORMAT_LAST = SND_PCM_FORMAT_U18_3BE,
 SND_PCM_FORMAT_S16 = SND_PCM_FORMAT_S16_LE,
 SND_PCM_FORMAT_U16 = SND_PCM_FORMAT_U16_LE,
 SND_PCM_FORMAT_S24 = SND_PCM_FORMAT_S24_LE,
 SND_PCM_FORMAT_U24 = SND_PCM_FORMAT_U24_LE,
 SND_PCM_FORMAT_S32 = SND_PCM_FORMAT_S32_LE,
 SND_PCM_FORMAT_U32 = SND_PCM_FORMAT_U32_LE,
 SND_PCM_FORMAT_FLOAT = SND_PCM_FORMAT_FLOAT_LE,
 SND_PCM_FORMAT_FLOAT64 = SND_PCM_FORMAT_FLOAT64_LE,
 SND_PCM_FORMAT_IEC958_SUBFRAME = SND_PCM_FORMAT_IEC958_SUBFRAME_LE
} snd_pcm_format_t;
typedef enum _snd_pcm_subformat {
 SND_PCM_SUBFORMAT_STD = 0,
 SND_PCM_SUBFORMAT_LAST = SND_PCM_SUBFORMAT_STD
} snd_pcm_subformat_t;
typedef enum _snd_pcm_state {
 SND_PCM_STATE_OPEN = 0,
 SND_PCM_STATE_SETUP,
 SND_PCM_STATE_PREPARED,
 SND_PCM_STATE_RUNNING,
 SND_PCM_STATE_XRUN,
 SND_PCM_STATE_DRAINING,
 SND_PCM_STATE_PAUSED,
 SND_PCM_STATE_SUSPENDED,
 SND_PCM_STATE_DISCONNECTED,
 SND_PCM_STATE_LAST = SND_PCM_STATE_DISCONNECTED
} snd_pcm_state_t;
typedef enum _snd_pcm_start {
 SND_PCM_START_DATA = 0,
 SND_PCM_START_EXPLICIT,
 SND_PCM_START_LAST = SND_PCM_START_EXPLICIT
} snd_pcm_start_t;
typedef enum _snd_pcm_xrun {
 SND_PCM_XRUN_NONE = 0,
 SND_PCM_XRUN_STOP,
 SND_PCM_XRUN_LAST = SND_PCM_XRUN_STOP
} snd_pcm_xrun_t;
typedef enum _snd_pcm_tstamp {
 SND_PCM_TSTAMP_NONE = 0,
 SND_PCM_TSTAMP_ENABLE,
 SND_PCM_TSTAMP_MMAP = SND_PCM_TSTAMP_ENABLE,
 SND_PCM_TSTAMP_LAST = SND_PCM_TSTAMP_ENABLE
} snd_pcm_tstamp_t;
typedef unsigned long snd_pcm_uframes_t;
typedef long snd_pcm_sframes_t;
enum {
	SND_PCM_NONBLOCK     = 0x00000001,
	SND_PCM_ASYNC        = 0x00000002,
	SND_PCM_NO_AUTO_RESAMPLE = 0x00010000,
	SND_PCM_NO_AUTO_CHANNELS = 0x00020000,
	SND_PCM_NO_AUTO_FORMAT = 0x00040000,
	SND_PCM_NO_SOFTVOL   = 0x00080000,
};
typedef struct _snd_pcm snd_pcm_t;
enum _snd_pcm_type {
 SND_PCM_TYPE_HW = 0,
 SND_PCM_TYPE_HOOKS,
 SND_PCM_TYPE_MULTI,
 SND_PCM_TYPE_FILE,
 SND_PCM_TYPE_NULL,
 SND_PCM_TYPE_SHM,
 SND_PCM_TYPE_INET,
 SND_PCM_TYPE_COPY,
 SND_PCM_TYPE_LINEAR,
 SND_PCM_TYPE_ALAW,
 SND_PCM_TYPE_MULAW,
 SND_PCM_TYPE_ADPCM,
 SND_PCM_TYPE_RATE,
 SND_PCM_TYPE_ROUTE,
 SND_PCM_TYPE_PLUG,
 SND_PCM_TYPE_SHARE,
 SND_PCM_TYPE_METER,
 SND_PCM_TYPE_MIX,
 SND_PCM_TYPE_DROUTE,
 SND_PCM_TYPE_LBSERVER,
 SND_PCM_TYPE_LINEAR_FLOAT,
 SND_PCM_TYPE_LADSPA,
 SND_PCM_TYPE_DMIX,
 SND_PCM_TYPE_JACK,
 SND_PCM_TYPE_DSNOOP,
 SND_PCM_TYPE_DSHARE,
 SND_PCM_TYPE_IEC958,
 SND_PCM_TYPE_SOFTVOL,
 SND_PCM_TYPE_IOPLUG,
 SND_PCM_TYPE_EXTPLUG,
 SND_PCM_TYPE_MMAP_EMUL,
 SND_PCM_TYPE_LAST = SND_PCM_TYPE_MMAP_EMUL
};
typedef enum _snd_pcm_type snd_pcm_type_t;
typedef struct _snd_pcm_channel_area {
 void *addr;
 unsigned int first;
 unsigned int step;
} snd_pcm_channel_area_t;
typedef union _snd_pcm_sync_id {
 unsigned char id[16];
 unsigned short id16[8];
 unsigned int id32[4];
} snd_pcm_sync_id_t;
typedef struct _snd_pcm_scope snd_pcm_scope_t;
int snd_pcm_open(snd_pcm_t **pcm, const char *name,
   snd_pcm_stream_t stream, int mode);
int snd_pcm_open_lconf(snd_pcm_t **pcm, const char *name,
         snd_pcm_stream_t stream, int mode,
         snd_config_t *lconf);
int snd_pcm_close(snd_pcm_t *pcm);
const char *snd_pcm_name(snd_pcm_t *pcm);
snd_pcm_type_t snd_pcm_type(snd_pcm_t *pcm);
snd_pcm_stream_t snd_pcm_stream(snd_pcm_t *pcm);
int snd_pcm_poll_descriptors_count(snd_pcm_t *pcm);
int snd_pcm_poll_descriptors(snd_pcm_t *pcm, struct pollfd *pfds, unsigned int space);
int snd_pcm_poll_descriptors_revents(snd_pcm_t *pcm, struct pollfd *pfds, unsigned int nfds, unsigned short *revents);
int snd_pcm_nonblock(snd_pcm_t *pcm, int nonblock);
int snd_async_add_pcm_handler(snd_async_handler_t **handler, snd_pcm_t *pcm,
         snd_async_callback_t callback, void *private_data);
snd_pcm_t *snd_async_handler_get_pcm(snd_async_handler_t *handler);
int snd_pcm_info(snd_pcm_t *pcm, snd_pcm_info_t *info);
int snd_pcm_hw_params_current(snd_pcm_t *pcm, snd_pcm_hw_params_t *params);
int snd_pcm_hw_params(snd_pcm_t *pcm, snd_pcm_hw_params_t *params);
int snd_pcm_hw_free(snd_pcm_t *pcm);
int snd_pcm_sw_params_current(snd_pcm_t *pcm, snd_pcm_sw_params_t *params);
int snd_pcm_sw_params(snd_pcm_t *pcm, snd_pcm_sw_params_t *params);
int snd_pcm_prepare(snd_pcm_t *pcm);
int snd_pcm_reset(snd_pcm_t *pcm);
int snd_pcm_status(snd_pcm_t *pcm, snd_pcm_status_t *status);
int snd_pcm_start(snd_pcm_t *pcm);
int snd_pcm_drop(snd_pcm_t *pcm);
int snd_pcm_drain(snd_pcm_t *pcm);
int snd_pcm_pause(snd_pcm_t *pcm, int enable);
snd_pcm_state_t snd_pcm_state(snd_pcm_t *pcm);
int snd_pcm_hwsync(snd_pcm_t *pcm);
int snd_pcm_delay(snd_pcm_t *pcm, snd_pcm_sframes_t *delayp);
int snd_pcm_resume(snd_pcm_t *pcm);
int snd_pcm_htimestamp(snd_pcm_t *pcm, snd_pcm_uframes_t *avail, snd_htimestamp_t *tstamp);
snd_pcm_sframes_t snd_pcm_avail(snd_pcm_t *pcm);
snd_pcm_sframes_t snd_pcm_avail_update(snd_pcm_t *pcm);
int snd_pcm_avail_delay(snd_pcm_t *pcm, snd_pcm_sframes_t *availp, snd_pcm_sframes_t *delayp);
snd_pcm_sframes_t snd_pcm_rewindable(snd_pcm_t *pcm);
snd_pcm_sframes_t snd_pcm_rewind(snd_pcm_t *pcm, snd_pcm_uframes_t frames);
snd_pcm_sframes_t snd_pcm_forwardable(snd_pcm_t *pcm);
snd_pcm_sframes_t snd_pcm_forward(snd_pcm_t *pcm, snd_pcm_uframes_t frames);
snd_pcm_sframes_t snd_pcm_writei(snd_pcm_t *pcm, const void *buffer, snd_pcm_uframes_t size);
snd_pcm_sframes_t snd_pcm_readi(snd_pcm_t *pcm, void *buffer, snd_pcm_uframes_t size);
snd_pcm_sframes_t snd_pcm_writen(snd_pcm_t *pcm, void **bufs, snd_pcm_uframes_t size);
snd_pcm_sframes_t snd_pcm_readn(snd_pcm_t *pcm, void **bufs, snd_pcm_uframes_t size);
int snd_pcm_wait(snd_pcm_t *pcm, int timeout);
int snd_pcm_link(snd_pcm_t *pcm1, snd_pcm_t *pcm2);
int snd_pcm_unlink(snd_pcm_t *pcm);
int snd_pcm_recover(snd_pcm_t *pcm, int err, int silent);
int snd_pcm_set_params(snd_pcm_t *pcm,
                       snd_pcm_format_t format,
                       snd_pcm_access_t access,
                       unsigned int channels,
                       unsigned int rate,
                       int soft_resample,
                       unsigned int latency);
int snd_pcm_get_params(snd_pcm_t *pcm,
                       snd_pcm_uframes_t *buffer_size,
                       snd_pcm_uframes_t *period_size);
size_t snd_pcm_info_sizeof(void);
int snd_pcm_info_malloc(snd_pcm_info_t **ptr);
void snd_pcm_info_free(snd_pcm_info_t *obj);
void snd_pcm_info_copy(snd_pcm_info_t *dst, const snd_pcm_info_t *src);
unsigned int snd_pcm_info_get_device(const snd_pcm_info_t *obj);
unsigned int snd_pcm_info_get_subdevice(const snd_pcm_info_t *obj);
snd_pcm_stream_t snd_pcm_info_get_stream(const snd_pcm_info_t *obj);
int snd_pcm_info_get_card(const snd_pcm_info_t *obj);
const char *snd_pcm_info_get_id(const snd_pcm_info_t *obj);
const char *snd_pcm_info_get_name(const snd_pcm_info_t *obj);
const char *snd_pcm_info_get_subdevice_name(const snd_pcm_info_t *obj);
snd_pcm_class_t snd_pcm_info_get_class(const snd_pcm_info_t *obj);
snd_pcm_subclass_t snd_pcm_info_get_subclass(const snd_pcm_info_t *obj);
unsigned int snd_pcm_info_get_subdevices_count(const snd_pcm_info_t *obj);
unsigned int snd_pcm_info_get_subdevices_avail(const snd_pcm_info_t *obj);
snd_pcm_sync_id_t snd_pcm_info_get_sync(const snd_pcm_info_t *obj);
void snd_pcm_info_set_device(snd_pcm_info_t *obj, unsigned int val);
void snd_pcm_info_set_subdevice(snd_pcm_info_t *obj, unsigned int val);
void snd_pcm_info_set_stream(snd_pcm_info_t *obj, snd_pcm_stream_t val);
int snd_pcm_hw_params_any(snd_pcm_t *pcm, snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_can_mmap_sample_resolution(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_is_double(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_is_batch(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_is_block_transfer(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_is_monotonic(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_can_overrange(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_can_pause(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_can_resume(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_is_half_duplex(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_is_joint_duplex(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_can_sync_start(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_get_rate_numden(const snd_pcm_hw_params_t *params,
          unsigned int *rate_num,
          unsigned int *rate_den);
int snd_pcm_hw_params_get_sbits(const snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_get_fifo_size(const snd_pcm_hw_params_t *params);
size_t snd_pcm_hw_params_sizeof(void);
int snd_pcm_hw_params_malloc(snd_pcm_hw_params_t **ptr);
void snd_pcm_hw_params_free(snd_pcm_hw_params_t *obj);
void snd_pcm_hw_params_copy(snd_pcm_hw_params_t *dst, const snd_pcm_hw_params_t *src);
int snd_pcm_hw_params_get_access(const snd_pcm_hw_params_t *params, snd_pcm_access_t *_access);
int snd_pcm_hw_params_test_access(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_access_t _access);
int snd_pcm_hw_params_set_access(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_access_t _access);
int snd_pcm_hw_params_set_access_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_access_t *_access);
int snd_pcm_hw_params_set_access_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_access_t *_access);
int snd_pcm_hw_params_set_access_mask(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_access_mask_t *mask);
int snd_pcm_hw_params_get_access_mask(snd_pcm_hw_params_t *params, snd_pcm_access_mask_t *mask);
int snd_pcm_hw_params_get_format(const snd_pcm_hw_params_t *params, snd_pcm_format_t *val);
int snd_pcm_hw_params_test_format(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_format_t val);
int snd_pcm_hw_params_set_format(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_format_t val);
int snd_pcm_hw_params_set_format_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_format_t *format);
int snd_pcm_hw_params_set_format_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_format_t *format);
int snd_pcm_hw_params_set_format_mask(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_format_mask_t *mask);
void snd_pcm_hw_params_get_format_mask(snd_pcm_hw_params_t *params, snd_pcm_format_mask_t *mask);
int snd_pcm_hw_params_get_subformat(const snd_pcm_hw_params_t *params, snd_pcm_subformat_t *subformat);
int snd_pcm_hw_params_test_subformat(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_subformat_t subformat);
int snd_pcm_hw_params_set_subformat(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_subformat_t subformat);
int snd_pcm_hw_params_set_subformat_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_subformat_t *subformat);
int snd_pcm_hw_params_set_subformat_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_subformat_t *subformat);
int snd_pcm_hw_params_set_subformat_mask(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_subformat_mask_t *mask);
void snd_pcm_hw_params_get_subformat_mask(snd_pcm_hw_params_t *params, snd_pcm_subformat_mask_t *mask);
int snd_pcm_hw_params_get_channels(const snd_pcm_hw_params_t *params, unsigned int *val);
int snd_pcm_hw_params_get_channels_min(const snd_pcm_hw_params_t *params, unsigned int *val);
int snd_pcm_hw_params_get_channels_max(const snd_pcm_hw_params_t *params, unsigned int *val);
int snd_pcm_hw_params_test_channels(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val);
int snd_pcm_hw_params_set_channels(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val);
int snd_pcm_hw_params_set_channels_min(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val);
int snd_pcm_hw_params_set_channels_max(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val);
int snd_pcm_hw_params_set_channels_minmax(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *min, unsigned int *max);
int snd_pcm_hw_params_set_channels_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val);
int snd_pcm_hw_params_set_channels_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val);
int snd_pcm_hw_params_set_channels_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val);
int snd_pcm_hw_params_get_rate(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_get_rate_min(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_get_rate_max(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_test_rate(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val, int dir);
int snd_pcm_hw_params_set_rate(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val, int dir);
int snd_pcm_hw_params_set_rate_min(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_rate_max(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_rate_minmax(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *min, int *mindir, unsigned int *max, int *maxdir);
int snd_pcm_hw_params_set_rate_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_rate_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_rate_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_rate_resample(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val);
int snd_pcm_hw_params_get_rate_resample(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val);
int snd_pcm_hw_params_set_export_buffer(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val);
int snd_pcm_hw_params_get_export_buffer(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val);
int snd_pcm_hw_params_get_period_time(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_get_period_time_min(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_get_period_time_max(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_test_period_time(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val, int dir);
int snd_pcm_hw_params_set_period_time(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val, int dir);
int snd_pcm_hw_params_set_period_time_min(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_period_time_max(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_period_time_minmax(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *min, int *mindir, unsigned int *max, int *maxdir);
int snd_pcm_hw_params_set_period_time_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_period_time_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_period_time_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_get_period_size(const snd_pcm_hw_params_t *params, snd_pcm_uframes_t *frames, int *dir);
int snd_pcm_hw_params_get_period_size_min(const snd_pcm_hw_params_t *params, snd_pcm_uframes_t *frames, int *dir);
int snd_pcm_hw_params_get_period_size_max(const snd_pcm_hw_params_t *params, snd_pcm_uframes_t *frames, int *dir);
int snd_pcm_hw_params_test_period_size(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t val, int dir);
int snd_pcm_hw_params_set_period_size(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t val, int dir);
int snd_pcm_hw_params_set_period_size_min(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val, int *dir);
int snd_pcm_hw_params_set_period_size_max(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val, int *dir);
int snd_pcm_hw_params_set_period_size_minmax(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *min, int *mindir, snd_pcm_uframes_t *max, int *maxdir);
int snd_pcm_hw_params_set_period_size_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val, int *dir);
int snd_pcm_hw_params_set_period_size_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val, int *dir);
int snd_pcm_hw_params_set_period_size_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val, int *dir);
int snd_pcm_hw_params_set_period_size_integer(snd_pcm_t *pcm, snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_get_periods(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_get_periods_min(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_get_periods_max(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_test_periods(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val, int dir);
int snd_pcm_hw_params_set_periods(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val, int dir);
int snd_pcm_hw_params_set_periods_min(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_periods_max(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_periods_minmax(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *min, int *mindir, unsigned int *max, int *maxdir);
int snd_pcm_hw_params_set_periods_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_periods_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_periods_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_periods_integer(snd_pcm_t *pcm, snd_pcm_hw_params_t *params);
int snd_pcm_hw_params_get_buffer_time(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_get_buffer_time_min(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_get_buffer_time_max(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_test_buffer_time(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val, int dir);
int snd_pcm_hw_params_set_buffer_time(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val, int dir);
int snd_pcm_hw_params_set_buffer_time_min(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_buffer_time_max(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_buffer_time_minmax(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *min, int *mindir, unsigned int *max, int *maxdir);
int snd_pcm_hw_params_set_buffer_time_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_buffer_time_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_set_buffer_time_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir);
int snd_pcm_hw_params_get_buffer_size(const snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_hw_params_get_buffer_size_min(const snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_hw_params_get_buffer_size_max(const snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_hw_params_test_buffer_size(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t val);
int snd_pcm_hw_params_set_buffer_size(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t val);
int snd_pcm_hw_params_set_buffer_size_min(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_hw_params_set_buffer_size_max(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_hw_params_set_buffer_size_minmax(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *min, snd_pcm_uframes_t *max);
int snd_pcm_hw_params_set_buffer_size_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_hw_params_set_buffer_size_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_hw_params_set_buffer_size_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_hw_params_get_min_align(const snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val);
size_t snd_pcm_sw_params_sizeof(void);
int snd_pcm_sw_params_malloc(snd_pcm_sw_params_t **ptr);
void snd_pcm_sw_params_free(snd_pcm_sw_params_t *obj);
void snd_pcm_sw_params_copy(snd_pcm_sw_params_t *dst, const snd_pcm_sw_params_t *src);
int snd_pcm_sw_params_get_boundary(const snd_pcm_sw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_sw_params_set_tstamp_mode(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_tstamp_t val);
int snd_pcm_sw_params_get_tstamp_mode(const snd_pcm_sw_params_t *params, snd_pcm_tstamp_t *val);
int snd_pcm_sw_params_set_avail_min(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_uframes_t val);
int snd_pcm_sw_params_get_avail_min(const snd_pcm_sw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_sw_params_set_period_event(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, int val);
int snd_pcm_sw_params_get_period_event(const snd_pcm_sw_params_t *params, int *val);
int snd_pcm_sw_params_set_start_threshold(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_uframes_t val);
int snd_pcm_sw_params_get_start_threshold(const snd_pcm_sw_params_t *paramsm, snd_pcm_uframes_t *val);
int snd_pcm_sw_params_set_stop_threshold(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_uframes_t val);
int snd_pcm_sw_params_get_stop_threshold(const snd_pcm_sw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_sw_params_set_silence_threshold(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_uframes_t val);
int snd_pcm_sw_params_get_silence_threshold(const snd_pcm_sw_params_t *params, snd_pcm_uframes_t *val);
int snd_pcm_sw_params_set_silence_size(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_uframes_t val);
int snd_pcm_sw_params_get_silence_size(const snd_pcm_sw_params_t *params, snd_pcm_uframes_t *val);
size_t snd_pcm_access_mask_sizeof(void);
int snd_pcm_access_mask_malloc(snd_pcm_access_mask_t **ptr);
void snd_pcm_access_mask_free(snd_pcm_access_mask_t *obj);
void snd_pcm_access_mask_copy(snd_pcm_access_mask_t *dst, const snd_pcm_access_mask_t *src);
void snd_pcm_access_mask_none(snd_pcm_access_mask_t *mask);
void snd_pcm_access_mask_any(snd_pcm_access_mask_t *mask);
int snd_pcm_access_mask_test(const snd_pcm_access_mask_t *mask, snd_pcm_access_t val);
int snd_pcm_access_mask_empty(const snd_pcm_access_mask_t *mask);
void snd_pcm_access_mask_set(snd_pcm_access_mask_t *mask, snd_pcm_access_t val);
void snd_pcm_access_mask_reset(snd_pcm_access_mask_t *mask, snd_pcm_access_t val);
size_t snd_pcm_format_mask_sizeof(void);
int snd_pcm_format_mask_malloc(snd_pcm_format_mask_t **ptr);
void snd_pcm_format_mask_free(snd_pcm_format_mask_t *obj);
void snd_pcm_format_mask_copy(snd_pcm_format_mask_t *dst, const snd_pcm_format_mask_t *src);
void snd_pcm_format_mask_none(snd_pcm_format_mask_t *mask);
void snd_pcm_format_mask_any(snd_pcm_format_mask_t *mask);
int snd_pcm_format_mask_test(const snd_pcm_format_mask_t *mask, snd_pcm_format_t val);
int snd_pcm_format_mask_empty(const snd_pcm_format_mask_t *mask);
void snd_pcm_format_mask_set(snd_pcm_format_mask_t *mask, snd_pcm_format_t val);
void snd_pcm_format_mask_reset(snd_pcm_format_mask_t *mask, snd_pcm_format_t val);
size_t snd_pcm_subformat_mask_sizeof(void);
int snd_pcm_subformat_mask_malloc(snd_pcm_subformat_mask_t **ptr);
void snd_pcm_subformat_mask_free(snd_pcm_subformat_mask_t *obj);
void snd_pcm_subformat_mask_copy(snd_pcm_subformat_mask_t *dst, const snd_pcm_subformat_mask_t *src);
void snd_pcm_subformat_mask_none(snd_pcm_subformat_mask_t *mask);
void snd_pcm_subformat_mask_any(snd_pcm_subformat_mask_t *mask);
int snd_pcm_subformat_mask_test(const snd_pcm_subformat_mask_t *mask, snd_pcm_subformat_t val);
int snd_pcm_subformat_mask_empty(const snd_pcm_subformat_mask_t *mask);
void snd_pcm_subformat_mask_set(snd_pcm_subformat_mask_t *mask, snd_pcm_subformat_t val);
void snd_pcm_subformat_mask_reset(snd_pcm_subformat_mask_t *mask, snd_pcm_subformat_t val);
size_t snd_pcm_status_sizeof(void);
int snd_pcm_status_malloc(snd_pcm_status_t **ptr);
void snd_pcm_status_free(snd_pcm_status_t *obj);
void snd_pcm_status_copy(snd_pcm_status_t *dst, const snd_pcm_status_t *src);
snd_pcm_state_t snd_pcm_status_get_state(const snd_pcm_status_t *obj);
void snd_pcm_status_get_trigger_tstamp(const snd_pcm_status_t *obj, snd_timestamp_t *ptr);
void snd_pcm_status_get_trigger_htstamp(const snd_pcm_status_t *obj, snd_htimestamp_t *ptr);
void snd_pcm_status_get_tstamp(const snd_pcm_status_t *obj, snd_timestamp_t *ptr);
void snd_pcm_status_get_htstamp(const snd_pcm_status_t *obj, snd_htimestamp_t *ptr);
snd_pcm_sframes_t snd_pcm_status_get_delay(const snd_pcm_status_t *obj);
snd_pcm_uframes_t snd_pcm_status_get_avail(const snd_pcm_status_t *obj);
snd_pcm_uframes_t snd_pcm_status_get_avail_max(const snd_pcm_status_t *obj);
snd_pcm_uframes_t snd_pcm_status_get_overrange(const snd_pcm_status_t *obj);
const char *snd_pcm_type_name(snd_pcm_type_t type);
const char *snd_pcm_stream_name(const snd_pcm_stream_t stream);
const char *snd_pcm_access_name(const snd_pcm_access_t _access);
const char *snd_pcm_format_name(const snd_pcm_format_t format);
const char *snd_pcm_format_description(const snd_pcm_format_t format);
const char *snd_pcm_subformat_name(const snd_pcm_subformat_t subformat);
const char *snd_pcm_subformat_description(const snd_pcm_subformat_t subformat);
snd_pcm_format_t snd_pcm_format_value(const char* name);
const char *snd_pcm_tstamp_mode_name(const snd_pcm_tstamp_t mode);
const char *snd_pcm_state_name(const snd_pcm_state_t state);
int snd_pcm_dump(snd_pcm_t *pcm, snd_output_t *out);
int snd_pcm_dump_hw_setup(snd_pcm_t *pcm, snd_output_t *out);
int snd_pcm_dump_sw_setup(snd_pcm_t *pcm, snd_output_t *out);
int snd_pcm_dump_setup(snd_pcm_t *pcm, snd_output_t *out);
int snd_pcm_hw_params_dump(snd_pcm_hw_params_t *params, snd_output_t *out);
int snd_pcm_sw_params_dump(snd_pcm_sw_params_t *params, snd_output_t *out);
int snd_pcm_status_dump(snd_pcm_status_t *status, snd_output_t *out);
int snd_pcm_mmap_begin(snd_pcm_t *pcm,
         const snd_pcm_channel_area_t **areas,
         snd_pcm_uframes_t *offset,
         snd_pcm_uframes_t *frames);
snd_pcm_sframes_t snd_pcm_mmap_commit(snd_pcm_t *pcm,
          snd_pcm_uframes_t offset,
          snd_pcm_uframes_t frames);
snd_pcm_sframes_t snd_pcm_mmap_writei(snd_pcm_t *pcm, const void *buffer, snd_pcm_uframes_t size);
snd_pcm_sframes_t snd_pcm_mmap_readi(snd_pcm_t *pcm, void *buffer, snd_pcm_uframes_t size);
snd_pcm_sframes_t snd_pcm_mmap_writen(snd_pcm_t *pcm, void **bufs, snd_pcm_uframes_t size);
snd_pcm_sframes_t snd_pcm_mmap_readn(snd_pcm_t *pcm, void **bufs, snd_pcm_uframes_t size);
int snd_pcm_format_signed(snd_pcm_format_t format);
int snd_pcm_format_unsigned(snd_pcm_format_t format);
int snd_pcm_format_linear(snd_pcm_format_t format);
int snd_pcm_format_float(snd_pcm_format_t format);
int snd_pcm_format_little_endian(snd_pcm_format_t format);
int snd_pcm_format_big_endian(snd_pcm_format_t format);
int snd_pcm_format_cpu_endian(snd_pcm_format_t format);
int snd_pcm_format_width(snd_pcm_format_t format);
int snd_pcm_format_physical_width(snd_pcm_format_t format);
snd_pcm_format_t snd_pcm_build_linear_format(int width, int pwidth, int unsignd, int big_endian);
ssize_t snd_pcm_format_size(snd_pcm_format_t format, size_t samples);
uint8_t snd_pcm_format_silence(snd_pcm_format_t format);
uint16_t snd_pcm_format_silence_16(snd_pcm_format_t format);
uint32_t snd_pcm_format_silence_32(snd_pcm_format_t format);
uint64_t snd_pcm_format_silence_64(snd_pcm_format_t format);
int snd_pcm_format_set_silence(snd_pcm_format_t format, void *buf, unsigned int samples);
snd_pcm_sframes_t snd_pcm_bytes_to_frames(snd_pcm_t *pcm, ssize_t bytes);
ssize_t snd_pcm_frames_to_bytes(snd_pcm_t *pcm, snd_pcm_sframes_t frames);
long snd_pcm_bytes_to_samples(snd_pcm_t *pcm, ssize_t bytes);
ssize_t snd_pcm_samples_to_bytes(snd_pcm_t *pcm, long samples);
int snd_pcm_area_silence(const snd_pcm_channel_area_t *dst_channel, snd_pcm_uframes_t dst_offset,
    unsigned int samples, snd_pcm_format_t format);
int snd_pcm_areas_silence(const snd_pcm_channel_area_t *dst_channels, snd_pcm_uframes_t dst_offset,
     unsigned int channels, snd_pcm_uframes_t frames, snd_pcm_format_t format);
int snd_pcm_area_copy(const snd_pcm_channel_area_t *dst_channel, snd_pcm_uframes_t dst_offset,
        const snd_pcm_channel_area_t *src_channel, snd_pcm_uframes_t src_offset,
        unsigned int samples, snd_pcm_format_t format);
int snd_pcm_areas_copy(const snd_pcm_channel_area_t *dst_channels, snd_pcm_uframes_t dst_offset,
         const snd_pcm_channel_area_t *src_channels, snd_pcm_uframes_t src_offset,
         unsigned int channels, snd_pcm_uframes_t frames, snd_pcm_format_t format);
typedef enum _snd_pcm_hook_type {
 SND_PCM_HOOK_TYPE_HW_PARAMS = 0,
 SND_PCM_HOOK_TYPE_HW_FREE,
 SND_PCM_HOOK_TYPE_CLOSE,
 SND_PCM_HOOK_TYPE_LAST = SND_PCM_HOOK_TYPE_CLOSE
} snd_pcm_hook_type_t;
typedef struct _snd_pcm_hook snd_pcm_hook_t;
typedef int (*snd_pcm_hook_func_t)(snd_pcm_hook_t *hook);
snd_pcm_t *snd_pcm_hook_get_pcm(snd_pcm_hook_t *hook);
void *snd_pcm_hook_get_private(snd_pcm_hook_t *hook);
void snd_pcm_hook_set_private(snd_pcm_hook_t *hook, void *private_data);
int snd_pcm_hook_add(snd_pcm_hook_t **hookp, snd_pcm_t *pcm,
       snd_pcm_hook_type_t type,
       snd_pcm_hook_func_t func, void *private_data);
int snd_pcm_hook_remove(snd_pcm_hook_t *hook);
typedef struct _snd_pcm_scope_ops {
 int (*enable)(snd_pcm_scope_t *scope);
 void (*disable)(snd_pcm_scope_t *scope);
 void (*start)(snd_pcm_scope_t *scope);
 void (*stop)(snd_pcm_scope_t *scope);
 void (*update)(snd_pcm_scope_t *scope);
 void (*reset)(snd_pcm_scope_t *scope);
 void (*close)(snd_pcm_scope_t *scope);
} snd_pcm_scope_ops_t;
snd_pcm_uframes_t snd_pcm_meter_get_bufsize(snd_pcm_t *pcm);
unsigned int snd_pcm_meter_get_channels(snd_pcm_t *pcm);
unsigned int snd_pcm_meter_get_rate(snd_pcm_t *pcm);
snd_pcm_uframes_t snd_pcm_meter_get_now(snd_pcm_t *pcm);
snd_pcm_uframes_t snd_pcm_meter_get_boundary(snd_pcm_t *pcm);
int snd_pcm_meter_add_scope(snd_pcm_t *pcm, snd_pcm_scope_t *scope);
snd_pcm_scope_t *snd_pcm_meter_search_scope(snd_pcm_t *pcm, const char *name);
int snd_pcm_scope_malloc(snd_pcm_scope_t **ptr);
void snd_pcm_scope_set_ops(snd_pcm_scope_t *scope,
      const snd_pcm_scope_ops_t *val);
void snd_pcm_scope_set_name(snd_pcm_scope_t *scope, const char *val);
const char *snd_pcm_scope_get_name(snd_pcm_scope_t *scope);
void *snd_pcm_scope_get_callback_private(snd_pcm_scope_t *scope);
void snd_pcm_scope_set_callback_private(snd_pcm_scope_t *scope, void *val);
int snd_pcm_scope_s16_open(snd_pcm_t *pcm, const char *name,
      snd_pcm_scope_t **scopep);
int16_t *snd_pcm_scope_s16_get_channel_buffer(snd_pcm_scope_t *scope,
           unsigned int channel);
typedef enum _snd_spcm_latency {
 SND_SPCM_LATENCY_STANDARD = 0,
 SND_SPCM_LATENCY_MEDIUM,
 SND_SPCM_LATENCY_REALTIME
} snd_spcm_latency_t;
typedef enum _snd_spcm_xrun_type {
 SND_SPCM_XRUN_IGNORE = 0,
 SND_SPCM_XRUN_STOP
} snd_spcm_xrun_type_t;
typedef enum _snd_spcm_duplex_type {
 SND_SPCM_DUPLEX_LIBERAL = 0,
 SND_SPCM_DUPLEX_PEDANTIC
} snd_spcm_duplex_type_t;
int snd_spcm_init(snd_pcm_t *pcm,
    unsigned int rate,
    unsigned int channels,
    snd_pcm_format_t format,
    snd_pcm_subformat_t subformat,
    snd_spcm_latency_t latency,
    snd_pcm_access_t _access,
    snd_spcm_xrun_type_t xrun_type);
int snd_spcm_init_duplex(snd_pcm_t *playback_pcm,
    snd_pcm_t *capture_pcm,
    unsigned int rate,
    unsigned int channels,
    snd_pcm_format_t format,
    snd_pcm_subformat_t subformat,
    snd_spcm_latency_t latency,
    snd_pcm_access_t _access,
    snd_spcm_xrun_type_t xrun_type,
    snd_spcm_duplex_type_t duplex_type);
int snd_spcm_init_get_params(snd_pcm_t *pcm,
        unsigned int *rate,
        snd_pcm_uframes_t *buffer_size,
        snd_pcm_uframes_t *period_size);
const char *snd_pcm_start_mode_name(snd_pcm_start_t mode) __attribute__((deprecated));
const char *snd_pcm_xrun_mode_name(snd_pcm_xrun_t mode) __attribute__((deprecated));
int snd_pcm_sw_params_set_start_mode(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_start_t val) __attribute__((deprecated));
snd_pcm_start_t snd_pcm_sw_params_get_start_mode(const snd_pcm_sw_params_t *params) __attribute__((deprecated));
int snd_pcm_sw_params_set_xrun_mode(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_xrun_t val) __attribute__((deprecated));
snd_pcm_xrun_t snd_pcm_sw_params_get_xrun_mode(const snd_pcm_sw_params_t *params) __attribute__((deprecated));
int snd_pcm_sw_params_set_xfer_align(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, snd_pcm_uframes_t val) __attribute__((deprecated));
int snd_pcm_sw_params_get_xfer_align(const snd_pcm_sw_params_t *params, snd_pcm_uframes_t *val) __attribute__((deprecated));
int snd_pcm_sw_params_set_sleep_min(snd_pcm_t *pcm, snd_pcm_sw_params_t *params, unsigned int val) __attribute__((deprecated));
int snd_pcm_sw_params_get_sleep_min(const snd_pcm_sw_params_t *params, unsigned int *val) __attribute__((deprecated));
int snd_pcm_hw_params_get_tick_time(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir) __attribute__((deprecated));
int snd_pcm_hw_params_get_tick_time_min(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir) __attribute__((deprecated));
int snd_pcm_hw_params_get_tick_time_max(const snd_pcm_hw_params_t *params, unsigned int *val, int *dir) __attribute__((deprecated));
int snd_pcm_hw_params_test_tick_time(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val, int dir) __attribute__((deprecated));
int snd_pcm_hw_params_set_tick_time(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int val, int dir) __attribute__((deprecated));
int snd_pcm_hw_params_set_tick_time_min(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir) __attribute__((deprecated));
int snd_pcm_hw_params_set_tick_time_max(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir) __attribute__((deprecated));
int snd_pcm_hw_params_set_tick_time_minmax(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *min, int *mindir, unsigned int *max, int *maxdir) __attribute__((deprecated));
int snd_pcm_hw_params_set_tick_time_near(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir) __attribute__((deprecated));
int snd_pcm_hw_params_set_tick_time_first(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir) __attribute__((deprecated));
int snd_pcm_hw_params_set_tick_time_last(snd_pcm_t *pcm, snd_pcm_hw_params_t *params, unsigned int *val, int *dir) __attribute__((deprecated));

// /usr/include/alsa/rawmidi.h
typedef struct _snd_rawmidi_info snd_rawmidi_info_t;
typedef struct _snd_rawmidi_params snd_rawmidi_params_t;
typedef struct _snd_rawmidi_status snd_rawmidi_status_t;
typedef enum _snd_rawmidi_stream {
 SND_RAWMIDI_STREAM_OUTPUT = 0,
 SND_RAWMIDI_STREAM_INPUT,
 SND_RAWMIDI_STREAM_LAST = SND_RAWMIDI_STREAM_INPUT
} snd_rawmidi_stream_t;
enum {
	SND_RAWMIDI_APPEND   = 0x0001,
	SND_RAWMIDI_NONBLOCK = 0x0002,
	SND_RAWMIDI_SYNC     = 0x0004,
};
typedef struct _snd_rawmidi snd_rawmidi_t;
typedef enum _snd_rawmidi_type {
 SND_RAWMIDI_TYPE_HW,
 SND_RAWMIDI_TYPE_SHM,
 SND_RAWMIDI_TYPE_INET,
 SND_RAWMIDI_TYPE_VIRTUAL
} snd_rawmidi_type_t;
int snd_rawmidi_open(snd_rawmidi_t **in_rmidi, snd_rawmidi_t **out_rmidi,
       const char *name, int mode);
int snd_rawmidi_open_lconf(snd_rawmidi_t **in_rmidi, snd_rawmidi_t **out_rmidi,
      const char *name, int mode, snd_config_t *lconf);
int snd_rawmidi_close(snd_rawmidi_t *rmidi);
int snd_rawmidi_poll_descriptors_count(snd_rawmidi_t *rmidi);
int snd_rawmidi_poll_descriptors(snd_rawmidi_t *rmidi, struct pollfd *pfds, unsigned int space);
int snd_rawmidi_poll_descriptors_revents(snd_rawmidi_t *rawmidi, struct pollfd *pfds, unsigned int nfds, unsigned short *revent);
int snd_rawmidi_nonblock(snd_rawmidi_t *rmidi, int nonblock);
size_t snd_rawmidi_info_sizeof(void);
int snd_rawmidi_info_malloc(snd_rawmidi_info_t **ptr);
void snd_rawmidi_info_free(snd_rawmidi_info_t *obj);
void snd_rawmidi_info_copy(snd_rawmidi_info_t *dst, const snd_rawmidi_info_t *src);
unsigned int snd_rawmidi_info_get_device(const snd_rawmidi_info_t *obj);
unsigned int snd_rawmidi_info_get_subdevice(const snd_rawmidi_info_t *obj);
snd_rawmidi_stream_t snd_rawmidi_info_get_stream(const snd_rawmidi_info_t *obj);
int snd_rawmidi_info_get_card(const snd_rawmidi_info_t *obj);
unsigned int snd_rawmidi_info_get_flags(const snd_rawmidi_info_t *obj);
const char *snd_rawmidi_info_get_id(const snd_rawmidi_info_t *obj);
const char *snd_rawmidi_info_get_name(const snd_rawmidi_info_t *obj);
const char *snd_rawmidi_info_get_subdevice_name(const snd_rawmidi_info_t *obj);
unsigned int snd_rawmidi_info_get_subdevices_count(const snd_rawmidi_info_t *obj);
unsigned int snd_rawmidi_info_get_subdevices_avail(const snd_rawmidi_info_t *obj);
void snd_rawmidi_info_set_device(snd_rawmidi_info_t *obj, unsigned int val);
void snd_rawmidi_info_set_subdevice(snd_rawmidi_info_t *obj, unsigned int val);
void snd_rawmidi_info_set_stream(snd_rawmidi_info_t *obj, snd_rawmidi_stream_t val);
int snd_rawmidi_info(snd_rawmidi_t *rmidi, snd_rawmidi_info_t * info);
size_t snd_rawmidi_params_sizeof(void);
int snd_rawmidi_params_malloc(snd_rawmidi_params_t **ptr);
void snd_rawmidi_params_free(snd_rawmidi_params_t *obj);
void snd_rawmidi_params_copy(snd_rawmidi_params_t *dst, const snd_rawmidi_params_t *src);
int snd_rawmidi_params_set_buffer_size(snd_rawmidi_t *rmidi, snd_rawmidi_params_t *params, size_t val);
size_t snd_rawmidi_params_get_buffer_size(const snd_rawmidi_params_t *params);
int snd_rawmidi_params_set_avail_min(snd_rawmidi_t *rmidi, snd_rawmidi_params_t *params, size_t val);
size_t snd_rawmidi_params_get_avail_min(const snd_rawmidi_params_t *params);
int snd_rawmidi_params_set_no_active_sensing(snd_rawmidi_t *rmidi, snd_rawmidi_params_t *params, int val);
int snd_rawmidi_params_get_no_active_sensing(const snd_rawmidi_params_t *params);
int snd_rawmidi_params(snd_rawmidi_t *rmidi, snd_rawmidi_params_t * params);
int snd_rawmidi_params_current(snd_rawmidi_t *rmidi, snd_rawmidi_params_t *params);
size_t snd_rawmidi_status_sizeof(void);
int snd_rawmidi_status_malloc(snd_rawmidi_status_t **ptr);
void snd_rawmidi_status_free(snd_rawmidi_status_t *obj);
void snd_rawmidi_status_copy(snd_rawmidi_status_t *dst, const snd_rawmidi_status_t *src);
void snd_rawmidi_status_get_tstamp(const snd_rawmidi_status_t *obj, snd_htimestamp_t *ptr);
size_t snd_rawmidi_status_get_avail(const snd_rawmidi_status_t *obj);
size_t snd_rawmidi_status_get_xruns(const snd_rawmidi_status_t *obj);
int snd_rawmidi_status(snd_rawmidi_t *rmidi, snd_rawmidi_status_t * status);
int snd_rawmidi_drain(snd_rawmidi_t *rmidi);
int snd_rawmidi_drop(snd_rawmidi_t *rmidi);
ssize_t snd_rawmidi_write(snd_rawmidi_t *rmidi, const void *buffer, size_t size);
ssize_t snd_rawmidi_read(snd_rawmidi_t *rmidi, void *buffer, size_t size);
const char *snd_rawmidi_name(snd_rawmidi_t *rmidi);
snd_rawmidi_type_t snd_rawmidi_type(snd_rawmidi_t *rmidi);
snd_rawmidi_stream_t snd_rawmidi_stream(snd_rawmidi_t *rawmidi);

// /usr/include/alsa/timer.h
typedef struct _snd_timer_id snd_timer_id_t;
typedef struct _snd_timer_ginfo snd_timer_ginfo_t;
typedef struct _snd_timer_gparams snd_timer_gparams_t;
typedef struct _snd_timer_gstatus snd_timer_gstatus_t;
typedef struct _snd_timer_info snd_timer_info_t;
typedef struct _snd_timer_params snd_timer_params_t;
typedef struct _snd_timer_status snd_timer_status_t;
typedef enum _snd_timer_class {
 SND_TIMER_CLASS_NONE = -1,
 SND_TIMER_CLASS_SLAVE = 0,
 SND_TIMER_CLASS_GLOBAL,
 SND_TIMER_CLASS_CARD,
 SND_TIMER_CLASS_PCM,
 SND_TIMER_CLASS_LAST = SND_TIMER_CLASS_PCM
} snd_timer_class_t;
typedef enum _snd_timer_slave_class {
 SND_TIMER_SCLASS_NONE = 0,
 SND_TIMER_SCLASS_APPLICATION,
 SND_TIMER_SCLASS_SEQUENCER,
 SND_TIMER_SCLASS_OSS_SEQUENCER,
 SND_TIMER_SCLASS_LAST = SND_TIMER_SCLASS_OSS_SEQUENCER
} snd_timer_slave_class_t;
typedef enum _snd_timer_event {
 SND_TIMER_EVENT_RESOLUTION = 0,
 SND_TIMER_EVENT_TICK,
 SND_TIMER_EVENT_START,
 SND_TIMER_EVENT_STOP,
 SND_TIMER_EVENT_CONTINUE,
 SND_TIMER_EVENT_PAUSE,
 SND_TIMER_EVENT_EARLY,
 SND_TIMER_EVENT_SUSPEND,
 SND_TIMER_EVENT_RESUME,
 SND_TIMER_EVENT_MSTART = SND_TIMER_EVENT_START + 10,
 SND_TIMER_EVENT_MSTOP = SND_TIMER_EVENT_STOP + 10,
 SND_TIMER_EVENT_MCONTINUE = SND_TIMER_EVENT_CONTINUE + 10,
 SND_TIMER_EVENT_MPAUSE = SND_TIMER_EVENT_PAUSE + 10,
 SND_TIMER_EVENT_MSUSPEND = SND_TIMER_EVENT_SUSPEND + 10,
 SND_TIMER_EVENT_MRESUME = SND_TIMER_EVENT_RESUME + 10
} snd_timer_event_t;
typedef struct _snd_timer_read {
 unsigned int resolution;
        unsigned int ticks;
} snd_timer_read_t;
typedef struct _snd_timer_tread {
 snd_timer_event_t event;
 snd_htimestamp_t tstamp;
 unsigned int val;
} snd_timer_tread_t;
enum {
	SND_TIMER_GLOBAL_SYSTEM = 0,
	SND_TIMER_GLOBAL_RTC = 1,
	SND_TIMER_GLOBAL_HPET = 2,
	SND_TIMER_GLOBAL_HRTIMER = 3,
	SND_TIMER_OPEN_NONBLOCK = (1<<0),
	SND_TIMER_OPEN_TREAD = (1<<1),
};
typedef enum _snd_timer_type {
 SND_TIMER_TYPE_HW = 0,
 SND_TIMER_TYPE_SHM,
 SND_TIMER_TYPE_INET
} snd_timer_type_t;
typedef struct _snd_timer_query snd_timer_query_t;
typedef struct _snd_timer snd_timer_t;
int snd_timer_query_open(snd_timer_query_t **handle, const char *name, int mode);
int snd_timer_query_open_lconf(snd_timer_query_t **handle, const char *name, int mode, snd_config_t *lconf);
int snd_timer_query_close(snd_timer_query_t *handle);
int snd_timer_query_next_device(snd_timer_query_t *handle, snd_timer_id_t *tid);
int snd_timer_query_info(snd_timer_query_t *handle, snd_timer_ginfo_t *info);
int snd_timer_query_params(snd_timer_query_t *handle, snd_timer_gparams_t *params);
int snd_timer_query_status(snd_timer_query_t *handle, snd_timer_gstatus_t *status);
int snd_timer_open(snd_timer_t **handle, const char *name, int mode);
int snd_timer_open_lconf(snd_timer_t **handle, const char *name, int mode, snd_config_t *lconf);
int snd_timer_close(snd_timer_t *handle);
int snd_async_add_timer_handler(snd_async_handler_t **handler, snd_timer_t *timer,
    snd_async_callback_t callback, void *private_data);
snd_timer_t *snd_async_handler_get_timer(snd_async_handler_t *handler);
int snd_timer_poll_descriptors_count(snd_timer_t *handle);
int snd_timer_poll_descriptors(snd_timer_t *handle, struct pollfd *pfds, unsigned int space);
int snd_timer_poll_descriptors_revents(snd_timer_t *timer, struct pollfd *pfds, unsigned int nfds, unsigned short *revents);
int snd_timer_info(snd_timer_t *handle, snd_timer_info_t *timer);
int snd_timer_params(snd_timer_t *handle, snd_timer_params_t *params);
int snd_timer_status(snd_timer_t *handle, snd_timer_status_t *status);
int snd_timer_start(snd_timer_t *handle);
int snd_timer_stop(snd_timer_t *handle);
int snd_timer_continue(snd_timer_t *handle);
ssize_t snd_timer_read(snd_timer_t *handle, void *buffer, size_t size);
size_t snd_timer_id_sizeof(void);
int snd_timer_id_malloc(snd_timer_id_t **ptr);
void snd_timer_id_free(snd_timer_id_t *obj);
void snd_timer_id_copy(snd_timer_id_t *dst, const snd_timer_id_t *src);
void snd_timer_id_set_class(snd_timer_id_t *id, int dev_class);
int snd_timer_id_get_class(snd_timer_id_t *id);
void snd_timer_id_set_sclass(snd_timer_id_t *id, int dev_sclass);
int snd_timer_id_get_sclass(snd_timer_id_t *id);
void snd_timer_id_set_card(snd_timer_id_t *id, int card);
int snd_timer_id_get_card(snd_timer_id_t *id);
void snd_timer_id_set_device(snd_timer_id_t *id, int device);
int snd_timer_id_get_device(snd_timer_id_t *id);
void snd_timer_id_set_subdevice(snd_timer_id_t *id, int subdevice);
int snd_timer_id_get_subdevice(snd_timer_id_t *id);
size_t snd_timer_ginfo_sizeof(void);
int snd_timer_ginfo_malloc(snd_timer_ginfo_t **ptr);
void snd_timer_ginfo_free(snd_timer_ginfo_t *obj);
void snd_timer_ginfo_copy(snd_timer_ginfo_t *dst, const snd_timer_ginfo_t *src);
int snd_timer_ginfo_set_tid(snd_timer_ginfo_t *obj, snd_timer_id_t *tid);
snd_timer_id_t *snd_timer_ginfo_get_tid(snd_timer_ginfo_t *obj);
unsigned int snd_timer_ginfo_get_flags(snd_timer_ginfo_t *obj);
int snd_timer_ginfo_get_card(snd_timer_ginfo_t *obj);
char *snd_timer_ginfo_get_id(snd_timer_ginfo_t *obj);
char *snd_timer_ginfo_get_name(snd_timer_ginfo_t *obj);
unsigned long snd_timer_ginfo_get_resolution(snd_timer_ginfo_t *obj);
unsigned long snd_timer_ginfo_get_resolution_min(snd_timer_ginfo_t *obj);
unsigned long snd_timer_ginfo_get_resolution_max(snd_timer_ginfo_t *obj);
unsigned int snd_timer_ginfo_get_clients(snd_timer_ginfo_t *obj);
size_t snd_timer_info_sizeof(void);
int snd_timer_info_malloc(snd_timer_info_t **ptr);
void snd_timer_info_free(snd_timer_info_t *obj);
void snd_timer_info_copy(snd_timer_info_t *dst, const snd_timer_info_t *src);
int snd_timer_info_is_slave(snd_timer_info_t * info);
int snd_timer_info_get_card(snd_timer_info_t * info);
const char *snd_timer_info_get_id(snd_timer_info_t * info);
const char *snd_timer_info_get_name(snd_timer_info_t * info);
long snd_timer_info_get_resolution(snd_timer_info_t * info);
size_t snd_timer_params_sizeof(void);
int snd_timer_params_malloc(snd_timer_params_t **ptr);
void snd_timer_params_free(snd_timer_params_t *obj);
void snd_timer_params_copy(snd_timer_params_t *dst, const snd_timer_params_t *src);
int snd_timer_params_set_auto_start(snd_timer_params_t * params, int auto_start);
int snd_timer_params_get_auto_start(snd_timer_params_t * params);
int snd_timer_params_set_exclusive(snd_timer_params_t * params, int exclusive);
int snd_timer_params_get_exclusive(snd_timer_params_t * params);
int snd_timer_params_set_early_event(snd_timer_params_t * params, int early_event);
int snd_timer_params_get_early_event(snd_timer_params_t * params);
void snd_timer_params_set_ticks(snd_timer_params_t * params, long ticks);
long snd_timer_params_get_ticks(snd_timer_params_t * params);
void snd_timer_params_set_queue_size(snd_timer_params_t * params, long queue_size);
long snd_timer_params_get_queue_size(snd_timer_params_t * params);
void snd_timer_params_set_filter(snd_timer_params_t * params, unsigned int filter);
unsigned int snd_timer_params_get_filter(snd_timer_params_t * params);
size_t snd_timer_status_sizeof(void);
int snd_timer_status_malloc(snd_timer_status_t **ptr);
void snd_timer_status_free(snd_timer_status_t *obj);
void snd_timer_status_copy(snd_timer_status_t *dst, const snd_timer_status_t *src);
snd_htimestamp_t snd_timer_status_get_timestamp(snd_timer_status_t * status);
long snd_timer_status_get_resolution(snd_timer_status_t * status);
long snd_timer_status_get_lost(snd_timer_status_t * status);
long snd_timer_status_get_overrun(snd_timer_status_t * status);
long snd_timer_status_get_queue(snd_timer_status_t * status);
long snd_timer_info_get_ticks(snd_timer_info_t * info);

// /usr/include/alsa/hwdep.h
typedef struct _snd_hwdep_info snd_hwdep_info_t;
typedef struct _snd_hwdep_dsp_status snd_hwdep_dsp_status_t;
typedef struct _snd_hwdep_dsp_image snd_hwdep_dsp_image_t;
typedef enum _snd_hwdep_iface {
 SND_HWDEP_IFACE_OPL2 = 0,
 SND_HWDEP_IFACE_OPL3,
 SND_HWDEP_IFACE_OPL4,
 SND_HWDEP_IFACE_SB16CSP,
 SND_HWDEP_IFACE_EMU10K1,
 SND_HWDEP_IFACE_YSS225,
 SND_HWDEP_IFACE_ICS2115,
 SND_HWDEP_IFACE_SSCAPE,
 SND_HWDEP_IFACE_VX,
 SND_HWDEP_IFACE_MIXART,
 SND_HWDEP_IFACE_USX2Y,
 SND_HWDEP_IFACE_EMUX_WAVETABLE,
 SND_HWDEP_IFACE_BLUETOOTH,
 SND_HWDEP_IFACE_USX2Y_PCM,
 SND_HWDEP_IFACE_PCXHR,
 SND_HWDEP_IFACE_SB_RC,
 SND_HWDEP_IFACE_LAST = SND_HWDEP_IFACE_SB_RC
} snd_hwdep_iface_t;
enum {
	SND_HWDEP_OPEN_READ  = (O_RDONLY),
	SND_HWDEP_OPEN_WRITE = (O_WRONLY),
	SND_HWDEP_OPEN_DUPLEX = (O_RDWR),
	SND_HWDEP_OPEN_NONBLOCK = (O_NONBLOCK),
};
typedef enum _snd_hwdep_type {
 SND_HWDEP_TYPE_HW,
 SND_HWDEP_TYPE_SHM,
 SND_HWDEP_TYPE_INET
} snd_hwdep_type_t;
typedef struct _snd_hwdep snd_hwdep_t;
int snd_hwdep_open(snd_hwdep_t **hwdep, const char *name, int mode);
int snd_hwdep_close(snd_hwdep_t *hwdep);
int snd_hwdep_poll_descriptors(snd_hwdep_t *hwdep, struct pollfd *pfds, unsigned int space);
int snd_hwdep_poll_descriptors_revents(snd_hwdep_t *hwdep, struct pollfd *pfds, unsigned int nfds, unsigned short *revents);
int snd_hwdep_nonblock(snd_hwdep_t *hwdep, int nonblock);
int snd_hwdep_info(snd_hwdep_t *hwdep, snd_hwdep_info_t * info);
int snd_hwdep_dsp_status(snd_hwdep_t *hwdep, snd_hwdep_dsp_status_t *status);
int snd_hwdep_dsp_load(snd_hwdep_t *hwdep, snd_hwdep_dsp_image_t *block);
int snd_hwdep_ioctl(snd_hwdep_t *hwdep, unsigned int request, void * arg);
ssize_t snd_hwdep_write(snd_hwdep_t *hwdep, const void *buffer, size_t size);
ssize_t snd_hwdep_read(snd_hwdep_t *hwdep, void *buffer, size_t size);
size_t snd_hwdep_info_sizeof(void);
int snd_hwdep_info_malloc(snd_hwdep_info_t **ptr);
void snd_hwdep_info_free(snd_hwdep_info_t *obj);
void snd_hwdep_info_copy(snd_hwdep_info_t *dst, const snd_hwdep_info_t *src);
unsigned int snd_hwdep_info_get_device(const snd_hwdep_info_t *obj);
int snd_hwdep_info_get_card(const snd_hwdep_info_t *obj);
const char *snd_hwdep_info_get_id(const snd_hwdep_info_t *obj);
const char *snd_hwdep_info_get_name(const snd_hwdep_info_t *obj);
snd_hwdep_iface_t snd_hwdep_info_get_iface(const snd_hwdep_info_t *obj);
void snd_hwdep_info_set_device(snd_hwdep_info_t *obj, unsigned int val);
size_t snd_hwdep_dsp_status_sizeof(void);
int snd_hwdep_dsp_status_malloc(snd_hwdep_dsp_status_t **ptr);
void snd_hwdep_dsp_status_free(snd_hwdep_dsp_status_t *obj);
void snd_hwdep_dsp_status_copy(snd_hwdep_dsp_status_t *dst, const snd_hwdep_dsp_status_t *src);
unsigned int snd_hwdep_dsp_status_get_version(const snd_hwdep_dsp_status_t *obj);
const char *snd_hwdep_dsp_status_get_id(const snd_hwdep_dsp_status_t *obj);
unsigned int snd_hwdep_dsp_status_get_num_dsps(const snd_hwdep_dsp_status_t *obj);
unsigned int snd_hwdep_dsp_status_get_dsp_loaded(const snd_hwdep_dsp_status_t *obj);
unsigned int snd_hwdep_dsp_status_get_chip_ready(const snd_hwdep_dsp_status_t *obj);
size_t snd_hwdep_dsp_image_sizeof(void);
int snd_hwdep_dsp_image_malloc(snd_hwdep_dsp_image_t **ptr);
void snd_hwdep_dsp_image_free(snd_hwdep_dsp_image_t *obj);
void snd_hwdep_dsp_image_copy(snd_hwdep_dsp_image_t *dst, const snd_hwdep_dsp_image_t *src);
unsigned int snd_hwdep_dsp_image_get_index(const snd_hwdep_dsp_image_t *obj);
const char *snd_hwdep_dsp_image_get_name(const snd_hwdep_dsp_image_t *obj);
const void *snd_hwdep_dsp_image_get_image(const snd_hwdep_dsp_image_t *obj);
size_t snd_hwdep_dsp_image_get_length(const snd_hwdep_dsp_image_t *obj);
void snd_hwdep_dsp_image_set_index(snd_hwdep_dsp_image_t *obj, unsigned int _index);
void snd_hwdep_dsp_image_set_name(snd_hwdep_dsp_image_t *obj, const char *name);
void snd_hwdep_dsp_image_set_image(snd_hwdep_dsp_image_t *obj, void *buffer);
void snd_hwdep_dsp_image_set_length(snd_hwdep_dsp_image_t *obj, size_t length);

// /usr/include/alsa/control.h
typedef struct snd_aes_iec958 {
 unsigned char status[24];
 unsigned char subcode[147];
 unsigned char pad;
 unsigned char dig_subframe[4];
} snd_aes_iec958_t;
typedef struct _snd_ctl_card_info snd_ctl_card_info_t;
typedef struct _snd_ctl_elem_id snd_ctl_elem_id_t;
typedef struct _snd_ctl_elem_list snd_ctl_elem_list_t;
typedef struct _snd_ctl_elem_info snd_ctl_elem_info_t;
typedef struct _snd_ctl_elem_value snd_ctl_elem_value_t;
typedef struct _snd_ctl_event snd_ctl_event_t;
typedef enum _snd_ctl_elem_type {
 SND_CTL_ELEM_TYPE_NONE = 0,
 SND_CTL_ELEM_TYPE_BOOLEAN,
 SND_CTL_ELEM_TYPE_INTEGER,
 SND_CTL_ELEM_TYPE_ENUMERATED,
 SND_CTL_ELEM_TYPE_BYTES,
 SND_CTL_ELEM_TYPE_IEC958,
 SND_CTL_ELEM_TYPE_INTEGER64,
 SND_CTL_ELEM_TYPE_LAST = SND_CTL_ELEM_TYPE_INTEGER64
} snd_ctl_elem_type_t;
typedef enum _snd_ctl_elem_iface {
 SND_CTL_ELEM_IFACE_CARD = 0,
 SND_CTL_ELEM_IFACE_HWDEP,
 SND_CTL_ELEM_IFACE_MIXER,
 SND_CTL_ELEM_IFACE_PCM,
 SND_CTL_ELEM_IFACE_RAWMIDI,
 SND_CTL_ELEM_IFACE_TIMER,
 SND_CTL_ELEM_IFACE_SEQUENCER,
 SND_CTL_ELEM_IFACE_LAST = SND_CTL_ELEM_IFACE_SEQUENCER
} snd_ctl_elem_iface_t;
typedef enum _snd_ctl_event_type {
 SND_CTL_EVENT_ELEM = 0,
 SND_CTL_EVENT_LAST = SND_CTL_EVENT_ELEM
}snd_ctl_event_type_t;
enum {
	SND_CTL_EVENT_MASK_REMOVE = (~0U),
	SND_CTL_EVENT_MASK_VALUE = (1<<0),
	SND_CTL_EVENT_MASK_INFO = (1<<1),
	SND_CTL_EVENT_MASK_ADD = (1<<2),
	SND_CTL_EVENT_MASK_TLV = (1<<3),
	SND_CTL_NAME_NONE    = "",
	SND_CTL_NAME_PLAYBACK = "Playback ",
	SND_CTL_NAME_CAPTURE = "Capture ",
	SND_CTL_NAME_IEC958_NONE = "",
	SND_CTL_NAME_IEC958_SWITCH = "Switch",
	SND_CTL_NAME_IEC958_VOLUME = "Volume",
	SND_CTL_NAME_IEC958_DEFAULT = "Default",
	SND_CTL_NAME_IEC958_MASK = "Mask",
	SND_CTL_NAME_IEC958_CON_MASK = "Con Mask",
	SND_CTL_NAME_IEC958_PRO_MASK = "Pro Mask",
	SND_CTL_NAME_IEC958_PCM_STREAM = "PCM Stream",
};
enum {
	SND_CTL_POWER_MASK   = 0xff00,
	SND_CTL_POWER_D0     = 0x0000,
	SND_CTL_POWER_D1     = 0x0100,
	SND_CTL_POWER_D2     = 0x0200,
	SND_CTL_POWER_D3     = 0x0300,
	SND_CTL_POWER_D3hot  = (SND_CTL_POWER_D3|0x0000),
	SND_CTL_POWER_D3cold = (SND_CTL_POWER_D3|0x0001),
	SND_CTL_TLVT_CONTAINER = 0x0000,
	SND_CTL_TLVT_DB_SCALE = 0x0001,
	SND_CTL_TLVT_DB_LINEAR = 0x0002,
	SND_CTL_TLVT_DB_RANGE = 0x0003,
	SND_CTL_TLVT_DB_MINMAX = 0x0004,
	SND_CTL_TLVT_DB_MINMAX_MUTE = 0x0005,
	SND_CTL_TLV_DB_GAIN_MUTE = -9999999,
};
typedef enum _snd_ctl_type {
 SND_CTL_TYPE_HW,
 SND_CTL_TYPE_SHM,
 SND_CTL_TYPE_INET,
 SND_CTL_TYPE_EXT
} snd_ctl_type_t;
enum {
	SND_CTL_NONBLOCK     = 0x0001,
	SND_CTL_ASYNC        = 0x0002,
	SND_CTL_READONLY     = 0x0004,
};
typedef struct _snd_ctl snd_ctl_t;
enum {
	SND_SCTL_NOFREE      = 0x0001,
};
typedef struct _snd_sctl snd_sctl_t;
int snd_card_load(int card);
int snd_card_next(int *card);
int snd_card_get_index(const char *name);
int snd_card_get_name(int card, char **name);
int snd_card_get_longname(int card, char **name);
int snd_device_name_hint(int card, const char *iface, void ***hints);
int snd_device_name_free_hint(void **hints);
char *snd_device_name_get_hint(const void *hint, const char *id);
int snd_ctl_open(snd_ctl_t **ctl, const char *name, int mode);
int snd_ctl_open_lconf(snd_ctl_t **ctl, const char *name, int mode, snd_config_t *lconf);
int snd_ctl_close(snd_ctl_t *ctl);
int snd_ctl_nonblock(snd_ctl_t *ctl, int nonblock);
int snd_async_add_ctl_handler(snd_async_handler_t **handler, snd_ctl_t *ctl,
         snd_async_callback_t callback, void *private_data);
snd_ctl_t *snd_async_handler_get_ctl(snd_async_handler_t *handler);
int snd_ctl_poll_descriptors_count(snd_ctl_t *ctl);
int snd_ctl_poll_descriptors(snd_ctl_t *ctl, struct pollfd *pfds, unsigned int space);
int snd_ctl_poll_descriptors_revents(snd_ctl_t *ctl, struct pollfd *pfds, unsigned int nfds, unsigned short *revents);
int snd_ctl_subscribe_events(snd_ctl_t *ctl, int subscribe);
int snd_ctl_card_info(snd_ctl_t *ctl, snd_ctl_card_info_t *info);
int snd_ctl_elem_list(snd_ctl_t *ctl, snd_ctl_elem_list_t *list);
int snd_ctl_elem_info(snd_ctl_t *ctl, snd_ctl_elem_info_t *info);
int snd_ctl_elem_read(snd_ctl_t *ctl, snd_ctl_elem_value_t *value);
int snd_ctl_elem_write(snd_ctl_t *ctl, snd_ctl_elem_value_t *value);
int snd_ctl_elem_lock(snd_ctl_t *ctl, snd_ctl_elem_id_t *id);
int snd_ctl_elem_unlock(snd_ctl_t *ctl, snd_ctl_elem_id_t *id);
int snd_ctl_elem_tlv_read(snd_ctl_t *ctl, const snd_ctl_elem_id_t *id,
     unsigned int *tlv, unsigned int tlv_size);
int snd_ctl_elem_tlv_write(snd_ctl_t *ctl, const snd_ctl_elem_id_t *id,
      const unsigned int *tlv);
int snd_ctl_elem_tlv_command(snd_ctl_t *ctl, const snd_ctl_elem_id_t *id,
        const unsigned int *tlv);
int snd_ctl_hwdep_next_device(snd_ctl_t *ctl, int * device);
int snd_ctl_hwdep_info(snd_ctl_t *ctl, snd_hwdep_info_t * info);
int snd_ctl_pcm_next_device(snd_ctl_t *ctl, int *device);
int snd_ctl_pcm_info(snd_ctl_t *ctl, snd_pcm_info_t * info);
int snd_ctl_pcm_prefer_subdevice(snd_ctl_t *ctl, int subdev);
int snd_ctl_rawmidi_next_device(snd_ctl_t *ctl, int * device);
int snd_ctl_rawmidi_info(snd_ctl_t *ctl, snd_rawmidi_info_t * info);
int snd_ctl_rawmidi_prefer_subdevice(snd_ctl_t *ctl, int subdev);
int snd_ctl_set_power_state(snd_ctl_t *ctl, unsigned int state);
int snd_ctl_get_power_state(snd_ctl_t *ctl, unsigned int *state);
int snd_ctl_read(snd_ctl_t *ctl, snd_ctl_event_t *event);
int snd_ctl_wait(snd_ctl_t *ctl, int timeout);
const char *snd_ctl_name(snd_ctl_t *ctl);
snd_ctl_type_t snd_ctl_type(snd_ctl_t *ctl);
const char *snd_ctl_elem_type_name(snd_ctl_elem_type_t type);
const char *snd_ctl_elem_iface_name(snd_ctl_elem_iface_t iface);
const char *snd_ctl_event_type_name(snd_ctl_event_type_t type);
unsigned int snd_ctl_event_elem_get_mask(const snd_ctl_event_t *obj);
unsigned int snd_ctl_event_elem_get_numid(const snd_ctl_event_t *obj);
void snd_ctl_event_elem_get_id(const snd_ctl_event_t *obj, snd_ctl_elem_id_t *ptr);
snd_ctl_elem_iface_t snd_ctl_event_elem_get_interface(const snd_ctl_event_t *obj);
unsigned int snd_ctl_event_elem_get_device(const snd_ctl_event_t *obj);
unsigned int snd_ctl_event_elem_get_subdevice(const snd_ctl_event_t *obj);
const char *snd_ctl_event_elem_get_name(const snd_ctl_event_t *obj);
unsigned int snd_ctl_event_elem_get_index(const snd_ctl_event_t *obj);
int snd_ctl_elem_list_alloc_space(snd_ctl_elem_list_t *obj, unsigned int entries);
void snd_ctl_elem_list_free_space(snd_ctl_elem_list_t *obj);
size_t snd_ctl_elem_id_sizeof(void);
int snd_ctl_elem_id_malloc(snd_ctl_elem_id_t **ptr);
void snd_ctl_elem_id_free(snd_ctl_elem_id_t *obj);
void snd_ctl_elem_id_clear(snd_ctl_elem_id_t *obj);
void snd_ctl_elem_id_copy(snd_ctl_elem_id_t *dst, const snd_ctl_elem_id_t *src);
unsigned int snd_ctl_elem_id_get_numid(const snd_ctl_elem_id_t *obj);
snd_ctl_elem_iface_t snd_ctl_elem_id_get_interface(const snd_ctl_elem_id_t *obj);
unsigned int snd_ctl_elem_id_get_device(const snd_ctl_elem_id_t *obj);
unsigned int snd_ctl_elem_id_get_subdevice(const snd_ctl_elem_id_t *obj);
const char *snd_ctl_elem_id_get_name(const snd_ctl_elem_id_t *obj);
unsigned int snd_ctl_elem_id_get_index(const snd_ctl_elem_id_t *obj);
void snd_ctl_elem_id_set_numid(snd_ctl_elem_id_t *obj, unsigned int val);
void snd_ctl_elem_id_set_interface(snd_ctl_elem_id_t *obj, snd_ctl_elem_iface_t val);
void snd_ctl_elem_id_set_device(snd_ctl_elem_id_t *obj, unsigned int val);
void snd_ctl_elem_id_set_subdevice(snd_ctl_elem_id_t *obj, unsigned int val);
void snd_ctl_elem_id_set_name(snd_ctl_elem_id_t *obj, const char *val);
void snd_ctl_elem_id_set_index(snd_ctl_elem_id_t *obj, unsigned int val);
size_t snd_ctl_card_info_sizeof(void);
int snd_ctl_card_info_malloc(snd_ctl_card_info_t **ptr);
void snd_ctl_card_info_free(snd_ctl_card_info_t *obj);
void snd_ctl_card_info_clear(snd_ctl_card_info_t *obj);
void snd_ctl_card_info_copy(snd_ctl_card_info_t *dst, const snd_ctl_card_info_t *src);
int snd_ctl_card_info_get_card(const snd_ctl_card_info_t *obj);
const char *snd_ctl_card_info_get_id(const snd_ctl_card_info_t *obj);
const char *snd_ctl_card_info_get_driver(const snd_ctl_card_info_t *obj);
const char *snd_ctl_card_info_get_name(const snd_ctl_card_info_t *obj);
const char *snd_ctl_card_info_get_longname(const snd_ctl_card_info_t *obj);
const char *snd_ctl_card_info_get_mixername(const snd_ctl_card_info_t *obj);
const char *snd_ctl_card_info_get_components(const snd_ctl_card_info_t *obj);
size_t snd_ctl_event_sizeof(void);
int snd_ctl_event_malloc(snd_ctl_event_t **ptr);
void snd_ctl_event_free(snd_ctl_event_t *obj);
void snd_ctl_event_clear(snd_ctl_event_t *obj);
void snd_ctl_event_copy(snd_ctl_event_t *dst, const snd_ctl_event_t *src);
snd_ctl_event_type_t snd_ctl_event_get_type(const snd_ctl_event_t *obj);
size_t snd_ctl_elem_list_sizeof(void);
int snd_ctl_elem_list_malloc(snd_ctl_elem_list_t **ptr);
void snd_ctl_elem_list_free(snd_ctl_elem_list_t *obj);
void snd_ctl_elem_list_clear(snd_ctl_elem_list_t *obj);
void snd_ctl_elem_list_copy(snd_ctl_elem_list_t *dst, const snd_ctl_elem_list_t *src);
void snd_ctl_elem_list_set_offset(snd_ctl_elem_list_t *obj, unsigned int val);
unsigned int snd_ctl_elem_list_get_used(const snd_ctl_elem_list_t *obj);
unsigned int snd_ctl_elem_list_get_count(const snd_ctl_elem_list_t *obj);
void snd_ctl_elem_list_get_id(const snd_ctl_elem_list_t *obj, unsigned int idx, snd_ctl_elem_id_t *ptr);
unsigned int snd_ctl_elem_list_get_numid(const snd_ctl_elem_list_t *obj, unsigned int idx);
snd_ctl_elem_iface_t snd_ctl_elem_list_get_interface(const snd_ctl_elem_list_t *obj, unsigned int idx);
unsigned int snd_ctl_elem_list_get_device(const snd_ctl_elem_list_t *obj, unsigned int idx);
unsigned int snd_ctl_elem_list_get_subdevice(const snd_ctl_elem_list_t *obj, unsigned int idx);
const char *snd_ctl_elem_list_get_name(const snd_ctl_elem_list_t *obj, unsigned int idx);
unsigned int snd_ctl_elem_list_get_index(const snd_ctl_elem_list_t *obj, unsigned int idx);
size_t snd_ctl_elem_info_sizeof(void);
int snd_ctl_elem_info_malloc(snd_ctl_elem_info_t **ptr);
void snd_ctl_elem_info_free(snd_ctl_elem_info_t *obj);
void snd_ctl_elem_info_clear(snd_ctl_elem_info_t *obj);
void snd_ctl_elem_info_copy(snd_ctl_elem_info_t *dst, const snd_ctl_elem_info_t *src);
snd_ctl_elem_type_t snd_ctl_elem_info_get_type(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_is_readable(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_is_writable(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_is_volatile(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_is_inactive(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_is_locked(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_is_tlv_readable(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_is_tlv_writable(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_is_tlv_commandable(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_is_owner(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_is_user(const snd_ctl_elem_info_t *obj);
pid_t snd_ctl_elem_info_get_owner(const snd_ctl_elem_info_t *obj);
unsigned int snd_ctl_elem_info_get_count(const snd_ctl_elem_info_t *obj);
long snd_ctl_elem_info_get_min(const snd_ctl_elem_info_t *obj);
long snd_ctl_elem_info_get_max(const snd_ctl_elem_info_t *obj);
long snd_ctl_elem_info_get_step(const snd_ctl_elem_info_t *obj);
long long snd_ctl_elem_info_get_min64(const snd_ctl_elem_info_t *obj);
long long snd_ctl_elem_info_get_max64(const snd_ctl_elem_info_t *obj);
long long snd_ctl_elem_info_get_step64(const snd_ctl_elem_info_t *obj);
unsigned int snd_ctl_elem_info_get_items(const snd_ctl_elem_info_t *obj);
void snd_ctl_elem_info_set_item(snd_ctl_elem_info_t *obj, unsigned int val);
const char *snd_ctl_elem_info_get_item_name(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_get_dimensions(const snd_ctl_elem_info_t *obj);
int snd_ctl_elem_info_get_dimension(const snd_ctl_elem_info_t *obj, unsigned int idx);
void snd_ctl_elem_info_get_id(const snd_ctl_elem_info_t *obj, snd_ctl_elem_id_t *ptr);
unsigned int snd_ctl_elem_info_get_numid(const snd_ctl_elem_info_t *obj);
snd_ctl_elem_iface_t snd_ctl_elem_info_get_interface(const snd_ctl_elem_info_t *obj);
unsigned int snd_ctl_elem_info_get_device(const snd_ctl_elem_info_t *obj);
unsigned int snd_ctl_elem_info_get_subdevice(const snd_ctl_elem_info_t *obj);
const char *snd_ctl_elem_info_get_name(const snd_ctl_elem_info_t *obj);
unsigned int snd_ctl_elem_info_get_index(const snd_ctl_elem_info_t *obj);
void snd_ctl_elem_info_set_id(snd_ctl_elem_info_t *obj, const snd_ctl_elem_id_t *ptr);
void snd_ctl_elem_info_set_numid(snd_ctl_elem_info_t *obj, unsigned int val);
void snd_ctl_elem_info_set_interface(snd_ctl_elem_info_t *obj, snd_ctl_elem_iface_t val);
void snd_ctl_elem_info_set_device(snd_ctl_elem_info_t *obj, unsigned int val);
void snd_ctl_elem_info_set_subdevice(snd_ctl_elem_info_t *obj, unsigned int val);
void snd_ctl_elem_info_set_name(snd_ctl_elem_info_t *obj, const char *val);
void snd_ctl_elem_info_set_index(snd_ctl_elem_info_t *obj, unsigned int val);
int snd_ctl_elem_add_integer(snd_ctl_t *ctl, const snd_ctl_elem_id_t *id, unsigned int count, long imin, long imax, long istep);
int snd_ctl_elem_add_integer64(snd_ctl_t *ctl, const snd_ctl_elem_id_t *id, unsigned int count, long long imin, long long imax, long long istep);
int snd_ctl_elem_add_boolean(snd_ctl_t *ctl, const snd_ctl_elem_id_t *id, unsigned int count);
int snd_ctl_elem_add_iec958(snd_ctl_t *ctl, const snd_ctl_elem_id_t *id);
int snd_ctl_elem_remove(snd_ctl_t *ctl, snd_ctl_elem_id_t *id);
size_t snd_ctl_elem_value_sizeof(void);
int snd_ctl_elem_value_malloc(snd_ctl_elem_value_t **ptr);
void snd_ctl_elem_value_free(snd_ctl_elem_value_t *obj);
void snd_ctl_elem_value_clear(snd_ctl_elem_value_t *obj);
void snd_ctl_elem_value_copy(snd_ctl_elem_value_t *dst, const snd_ctl_elem_value_t *src);
int snd_ctl_elem_value_compare(snd_ctl_elem_value_t *left, const snd_ctl_elem_value_t *right);
void snd_ctl_elem_value_get_id(const snd_ctl_elem_value_t *obj, snd_ctl_elem_id_t *ptr);
unsigned int snd_ctl_elem_value_get_numid(const snd_ctl_elem_value_t *obj);
snd_ctl_elem_iface_t snd_ctl_elem_value_get_interface(const snd_ctl_elem_value_t *obj);
unsigned int snd_ctl_elem_value_get_device(const snd_ctl_elem_value_t *obj);
unsigned int snd_ctl_elem_value_get_subdevice(const snd_ctl_elem_value_t *obj);
const char *snd_ctl_elem_value_get_name(const snd_ctl_elem_value_t *obj);
unsigned int snd_ctl_elem_value_get_index(const snd_ctl_elem_value_t *obj);
void snd_ctl_elem_value_set_id(snd_ctl_elem_value_t *obj, const snd_ctl_elem_id_t *ptr);
void snd_ctl_elem_value_set_numid(snd_ctl_elem_value_t *obj, unsigned int val);
void snd_ctl_elem_value_set_interface(snd_ctl_elem_value_t *obj, snd_ctl_elem_iface_t val);
void snd_ctl_elem_value_set_device(snd_ctl_elem_value_t *obj, unsigned int val);
void snd_ctl_elem_value_set_subdevice(snd_ctl_elem_value_t *obj, unsigned int val);
void snd_ctl_elem_value_set_name(snd_ctl_elem_value_t *obj, const char *val);
void snd_ctl_elem_value_set_index(snd_ctl_elem_value_t *obj, unsigned int val);
int snd_ctl_elem_value_get_boolean(const snd_ctl_elem_value_t *obj, unsigned int idx);
long snd_ctl_elem_value_get_integer(const snd_ctl_elem_value_t *obj, unsigned int idx);
long long snd_ctl_elem_value_get_integer64(const snd_ctl_elem_value_t *obj, unsigned int idx);
unsigned int snd_ctl_elem_value_get_enumerated(const snd_ctl_elem_value_t *obj, unsigned int idx);
unsigned char snd_ctl_elem_value_get_byte(const snd_ctl_elem_value_t *obj, unsigned int idx);
void snd_ctl_elem_value_set_boolean(snd_ctl_elem_value_t *obj, unsigned int idx, long val);
void snd_ctl_elem_value_set_integer(snd_ctl_elem_value_t *obj, unsigned int idx, long val);
void snd_ctl_elem_value_set_integer64(snd_ctl_elem_value_t *obj, unsigned int idx, long long val);
void snd_ctl_elem_value_set_enumerated(snd_ctl_elem_value_t *obj, unsigned int idx, unsigned int val);
void snd_ctl_elem_value_set_byte(snd_ctl_elem_value_t *obj, unsigned int idx, unsigned char val);
void snd_ctl_elem_set_bytes(snd_ctl_elem_value_t *obj, void *data, size_t size);
const void * snd_ctl_elem_value_get_bytes(const snd_ctl_elem_value_t *obj);
void snd_ctl_elem_value_get_iec958(const snd_ctl_elem_value_t *obj, snd_aes_iec958_t *ptr);
void snd_ctl_elem_value_set_iec958(snd_ctl_elem_value_t *obj, const snd_aes_iec958_t *ptr);
int snd_tlv_parse_dB_info(unsigned int *tlv, unsigned int tlv_size,
     unsigned int **db_tlvp);
int snd_tlv_get_dB_range(unsigned int *tlv, long rangemin, long rangemax,
    long *min, long *max);
int snd_tlv_convert_to_dB(unsigned int *tlv, long rangemin, long rangemax,
     long volume, long *db_gain);
int snd_tlv_convert_from_dB(unsigned int *tlv, long rangemin, long rangemax,
       long db_gain, long *value, int xdir);
int snd_ctl_get_dB_range(snd_ctl_t *ctl, const snd_ctl_elem_id_t *id,
    long *min, long *max);
int snd_ctl_convert_to_dB(snd_ctl_t *ctl, const snd_ctl_elem_id_t *id,
     long volume, long *db_gain);
int snd_ctl_convert_from_dB(snd_ctl_t *ctl, const snd_ctl_elem_id_t *id,
       long db_gain, long *value, int xdir);
typedef struct _snd_hctl_elem snd_hctl_elem_t;
typedef struct _snd_hctl snd_hctl_t;
typedef int (*snd_hctl_compare_t)(const snd_hctl_elem_t *e1,
      const snd_hctl_elem_t *e2);
int snd_hctl_compare_fast(const snd_hctl_elem_t *c1,
     const snd_hctl_elem_t *c2);
typedef int (*snd_hctl_callback_t)(snd_hctl_t *hctl,
       unsigned int mask,
       snd_hctl_elem_t *elem);
typedef int (*snd_hctl_elem_callback_t)(snd_hctl_elem_t *elem,
     unsigned int mask);
int snd_hctl_open(snd_hctl_t **hctl, const char *name, int mode);
int snd_hctl_open_ctl(snd_hctl_t **hctlp, snd_ctl_t *ctl);
int snd_hctl_close(snd_hctl_t *hctl);
int snd_hctl_nonblock(snd_hctl_t *hctl, int nonblock);
int snd_hctl_poll_descriptors_count(snd_hctl_t *hctl);
int snd_hctl_poll_descriptors(snd_hctl_t *hctl, struct pollfd *pfds, unsigned int space);
int snd_hctl_poll_descriptors_revents(snd_hctl_t *ctl, struct pollfd *pfds, unsigned int nfds, unsigned short *revents);
unsigned int snd_hctl_get_count(snd_hctl_t *hctl);
int snd_hctl_set_compare(snd_hctl_t *hctl, snd_hctl_compare_t hsort);
snd_hctl_elem_t *snd_hctl_first_elem(snd_hctl_t *hctl);
snd_hctl_elem_t *snd_hctl_last_elem(snd_hctl_t *hctl);
snd_hctl_elem_t *snd_hctl_find_elem(snd_hctl_t *hctl, const snd_ctl_elem_id_t *id);
void snd_hctl_set_callback(snd_hctl_t *hctl, snd_hctl_callback_t callback);
void snd_hctl_set_callback_private(snd_hctl_t *hctl, void *data);
void *snd_hctl_get_callback_private(snd_hctl_t *hctl);
int snd_hctl_load(snd_hctl_t *hctl);
int snd_hctl_free(snd_hctl_t *hctl);
int snd_hctl_handle_events(snd_hctl_t *hctl);
const char *snd_hctl_name(snd_hctl_t *hctl);
int snd_hctl_wait(snd_hctl_t *hctl, int timeout);
snd_ctl_t *snd_hctl_ctl(snd_hctl_t *hctl);
snd_hctl_elem_t *snd_hctl_elem_next(snd_hctl_elem_t *elem);
snd_hctl_elem_t *snd_hctl_elem_prev(snd_hctl_elem_t *elem);
int snd_hctl_elem_info(snd_hctl_elem_t *elem, snd_ctl_elem_info_t * info);
int snd_hctl_elem_read(snd_hctl_elem_t *elem, snd_ctl_elem_value_t * value);
int snd_hctl_elem_write(snd_hctl_elem_t *elem, snd_ctl_elem_value_t * value);
int snd_hctl_elem_tlv_read(snd_hctl_elem_t *elem, unsigned int *tlv, unsigned int tlv_size);
int snd_hctl_elem_tlv_write(snd_hctl_elem_t *elem, const unsigned int *tlv);
int snd_hctl_elem_tlv_command(snd_hctl_elem_t *elem, const unsigned int *tlv);
snd_hctl_t *snd_hctl_elem_get_hctl(snd_hctl_elem_t *elem);
void snd_hctl_elem_get_id(const snd_hctl_elem_t *obj, snd_ctl_elem_id_t *ptr);
unsigned int snd_hctl_elem_get_numid(const snd_hctl_elem_t *obj);
snd_ctl_elem_iface_t snd_hctl_elem_get_interface(const snd_hctl_elem_t *obj);
unsigned int snd_hctl_elem_get_device(const snd_hctl_elem_t *obj);
unsigned int snd_hctl_elem_get_subdevice(const snd_hctl_elem_t *obj);
const char *snd_hctl_elem_get_name(const snd_hctl_elem_t *obj);
unsigned int snd_hctl_elem_get_index(const snd_hctl_elem_t *obj);
void snd_hctl_elem_set_callback(snd_hctl_elem_t *obj, snd_hctl_elem_callback_t val);
void * snd_hctl_elem_get_callback_private(const snd_hctl_elem_t *obj);
void snd_hctl_elem_set_callback_private(snd_hctl_elem_t *obj, void * val);
int snd_sctl_build(snd_sctl_t **ctl, snd_ctl_t *handle, snd_config_t *config,
     snd_config_t *private_data, int mode);
int snd_sctl_free(snd_sctl_t *handle);
int snd_sctl_install(snd_sctl_t *handle);
int snd_sctl_remove(snd_sctl_t *handle);

// /usr/include/alsa/mixer.h
typedef struct _snd_mixer snd_mixer_t;
typedef struct _snd_mixer_class snd_mixer_class_t;
typedef struct _snd_mixer_elem snd_mixer_elem_t;
typedef int (*snd_mixer_callback_t)(snd_mixer_t *ctl,
        unsigned int mask,
        snd_mixer_elem_t *elem);
typedef int (*snd_mixer_elem_callback_t)(snd_mixer_elem_t *elem,
      unsigned int mask);
typedef int (*snd_mixer_compare_t)(const snd_mixer_elem_t *e1,
       const snd_mixer_elem_t *e2);
typedef int (*snd_mixer_event_t)(snd_mixer_class_t *class_, unsigned int mask,
     snd_hctl_elem_t *helem, snd_mixer_elem_t *melem);
typedef enum _snd_mixer_elem_type {
 SND_MIXER_ELEM_SIMPLE,
 SND_MIXER_ELEM_LAST = SND_MIXER_ELEM_SIMPLE
} snd_mixer_elem_type_t;
int snd_mixer_open(snd_mixer_t **mixer, int mode);
int snd_mixer_close(snd_mixer_t *mixer);
snd_mixer_elem_t *snd_mixer_first_elem(snd_mixer_t *mixer);
snd_mixer_elem_t *snd_mixer_last_elem(snd_mixer_t *mixer);
int snd_mixer_handle_events(snd_mixer_t *mixer);
int snd_mixer_attach(snd_mixer_t *mixer, const char *name);
int snd_mixer_attach_hctl(snd_mixer_t *mixer, snd_hctl_t *hctl);
int snd_mixer_detach(snd_mixer_t *mixer, const char *name);
int snd_mixer_detach_hctl(snd_mixer_t *mixer, snd_hctl_t *hctl);
int snd_mixer_get_hctl(snd_mixer_t *mixer, const char *name, snd_hctl_t **hctl);
int snd_mixer_poll_descriptors_count(snd_mixer_t *mixer);
int snd_mixer_poll_descriptors(snd_mixer_t *mixer, struct pollfd *pfds, unsigned int space);
int snd_mixer_poll_descriptors_revents(snd_mixer_t *mixer, struct pollfd *pfds, unsigned int nfds, unsigned short *revents);
int snd_mixer_load(snd_mixer_t *mixer);
void snd_mixer_free(snd_mixer_t *mixer);
int snd_mixer_wait(snd_mixer_t *mixer, int timeout);
int snd_mixer_set_compare(snd_mixer_t *mixer, snd_mixer_compare_t msort);
void snd_mixer_set_callback(snd_mixer_t *obj, snd_mixer_callback_t val);
void * snd_mixer_get_callback_private(const snd_mixer_t *obj);
void snd_mixer_set_callback_private(snd_mixer_t *obj, void * val);
unsigned int snd_mixer_get_count(const snd_mixer_t *obj);
int snd_mixer_class_unregister(snd_mixer_class_t *clss);
snd_mixer_elem_t *snd_mixer_elem_next(snd_mixer_elem_t *elem);
snd_mixer_elem_t *snd_mixer_elem_prev(snd_mixer_elem_t *elem);
void snd_mixer_elem_set_callback(snd_mixer_elem_t *obj, snd_mixer_elem_callback_t val);
void * snd_mixer_elem_get_callback_private(const snd_mixer_elem_t *obj);
void snd_mixer_elem_set_callback_private(snd_mixer_elem_t *obj, void * val);
snd_mixer_elem_type_t snd_mixer_elem_get_type(const snd_mixer_elem_t *obj);
int snd_mixer_class_register(snd_mixer_class_t *class_, snd_mixer_t *mixer);
int snd_mixer_elem_new(snd_mixer_elem_t **elem,
         snd_mixer_elem_type_t type,
         int compare_weight,
         void *private_data,
         void (*private_free)(snd_mixer_elem_t *elem));
int snd_mixer_elem_add(snd_mixer_elem_t *elem, snd_mixer_class_t *class_);
int snd_mixer_elem_remove(snd_mixer_elem_t *elem);
void snd_mixer_elem_free(snd_mixer_elem_t *elem);
int snd_mixer_elem_info(snd_mixer_elem_t *elem);
int snd_mixer_elem_value(snd_mixer_elem_t *elem);
int snd_mixer_elem_attach(snd_mixer_elem_t *melem, snd_hctl_elem_t *helem);
int snd_mixer_elem_detach(snd_mixer_elem_t *melem, snd_hctl_elem_t *helem);
int snd_mixer_elem_empty(snd_mixer_elem_t *melem);
void *snd_mixer_elem_get_private(const snd_mixer_elem_t *melem);
size_t snd_mixer_class_sizeof(void);
int snd_mixer_class_malloc(snd_mixer_class_t **ptr);
void snd_mixer_class_free(snd_mixer_class_t *obj);
void snd_mixer_class_copy(snd_mixer_class_t *dst, const snd_mixer_class_t *src);
snd_mixer_t *snd_mixer_class_get_mixer(const snd_mixer_class_t *class_);
snd_mixer_event_t snd_mixer_class_get_event(const snd_mixer_class_t *class_);
void *snd_mixer_class_get_private(const snd_mixer_class_t *class_);
snd_mixer_compare_t snd_mixer_class_get_compare(const snd_mixer_class_t *class_);
int snd_mixer_class_set_event(snd_mixer_class_t *class_, snd_mixer_event_t event);
int snd_mixer_class_set_private(snd_mixer_class_t *class_, void *private_data);
int snd_mixer_class_set_private_free(snd_mixer_class_t *class_, void (*private_free)(snd_mixer_class_t *class_));
int snd_mixer_class_set_compare(snd_mixer_class_t *class_, snd_mixer_compare_t compare);
typedef enum _snd_mixer_selem_channel_id {
 SND_MIXER_SCHN_UNKNOWN = -1,
 SND_MIXER_SCHN_FRONT_LEFT = 0,
 SND_MIXER_SCHN_FRONT_RIGHT,
 SND_MIXER_SCHN_REAR_LEFT,
 SND_MIXER_SCHN_REAR_RIGHT,
 SND_MIXER_SCHN_FRONT_CENTER,
 SND_MIXER_SCHN_WOOFER,
 SND_MIXER_SCHN_SIDE_LEFT,
 SND_MIXER_SCHN_SIDE_RIGHT,
 SND_MIXER_SCHN_REAR_CENTER,
 SND_MIXER_SCHN_LAST = 31,
 SND_MIXER_SCHN_MONO = SND_MIXER_SCHN_FRONT_LEFT
} snd_mixer_selem_channel_id_t;
enum snd_mixer_selem_regopt_abstract {
 SND_MIXER_SABSTRACT_NONE = 0,
 SND_MIXER_SABSTRACT_BASIC,
};
struct snd_mixer_selem_regopt {
 int ver;
 enum snd_mixer_selem_regopt_abstract abstract;
 const char *device;
 snd_pcm_t *playback_pcm;
 snd_pcm_t *capture_pcm;
};
typedef struct _snd_mixer_selem_id snd_mixer_selem_id_t;
const char *snd_mixer_selem_channel_name(snd_mixer_selem_channel_id_t channel);
int snd_mixer_selem_register(snd_mixer_t *mixer,
        struct snd_mixer_selem_regopt *options,
        snd_mixer_class_t **classp);
void snd_mixer_selem_get_id(snd_mixer_elem_t *element,
       snd_mixer_selem_id_t *id);
const char *snd_mixer_selem_get_name(snd_mixer_elem_t *elem);
unsigned int snd_mixer_selem_get_index(snd_mixer_elem_t *elem);
snd_mixer_elem_t *snd_mixer_find_selem(snd_mixer_t *mixer,
           const snd_mixer_selem_id_t *id);
int snd_mixer_selem_is_active(snd_mixer_elem_t *elem);
int snd_mixer_selem_is_playback_mono(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_playback_channel(snd_mixer_elem_t *obj, snd_mixer_selem_channel_id_t channel);
int snd_mixer_selem_is_capture_mono(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_capture_channel(snd_mixer_elem_t *obj, snd_mixer_selem_channel_id_t channel);
int snd_mixer_selem_get_capture_group(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_common_volume(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_playback_volume(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_playback_volume_joined(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_capture_volume(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_capture_volume_joined(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_common_switch(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_playback_switch(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_playback_switch_joined(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_capture_switch(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_capture_switch_joined(snd_mixer_elem_t *elem);
int snd_mixer_selem_has_capture_switch_exclusive(snd_mixer_elem_t *elem);
int snd_mixer_selem_ask_playback_vol_dB(snd_mixer_elem_t *elem, long value, long *dBvalue);
int snd_mixer_selem_ask_capture_vol_dB(snd_mixer_elem_t *elem, long value, long *dBvalue);
int snd_mixer_selem_ask_playback_dB_vol(snd_mixer_elem_t *elem, long dBvalue, int dir, long *value);
int snd_mixer_selem_ask_capture_dB_vol(snd_mixer_elem_t *elem, long dBvalue, int dir, long *value);
int snd_mixer_selem_get_playback_volume(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, long *value);
int snd_mixer_selem_get_capture_volume(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, long *value);
int snd_mixer_selem_get_playback_dB(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, long *value);
int snd_mixer_selem_get_capture_dB(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, long *value);
int snd_mixer_selem_get_playback_switch(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, int *value);
int snd_mixer_selem_get_capture_switch(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, int *value);
int snd_mixer_selem_set_playback_volume(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, long value);
int snd_mixer_selem_set_capture_volume(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, long value);
int snd_mixer_selem_set_playback_dB(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, long value, int dir);
int snd_mixer_selem_set_capture_dB(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, long value, int dir);
int snd_mixer_selem_set_playback_volume_all(snd_mixer_elem_t *elem, long value);
int snd_mixer_selem_set_capture_volume_all(snd_mixer_elem_t *elem, long value);
int snd_mixer_selem_set_playback_dB_all(snd_mixer_elem_t *elem, long value, int dir);
int snd_mixer_selem_set_capture_dB_all(snd_mixer_elem_t *elem, long value, int dir);
int snd_mixer_selem_set_playback_switch(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, int value);
int snd_mixer_selem_set_capture_switch(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, int value);
int snd_mixer_selem_set_playback_switch_all(snd_mixer_elem_t *elem, int value);
int snd_mixer_selem_set_capture_switch_all(snd_mixer_elem_t *elem, int value);
int snd_mixer_selem_get_playback_volume_range(snd_mixer_elem_t *elem,
           long *min, long *max);
int snd_mixer_selem_get_playback_dB_range(snd_mixer_elem_t *elem,
       long *min, long *max);
int snd_mixer_selem_set_playback_volume_range(snd_mixer_elem_t *elem,
           long min, long max);
int snd_mixer_selem_get_capture_volume_range(snd_mixer_elem_t *elem,
          long *min, long *max);
int snd_mixer_selem_get_capture_dB_range(snd_mixer_elem_t *elem,
      long *min, long *max);
int snd_mixer_selem_set_capture_volume_range(snd_mixer_elem_t *elem,
          long min, long max);
int snd_mixer_selem_is_enumerated(snd_mixer_elem_t *elem);
int snd_mixer_selem_is_enum_playback(snd_mixer_elem_t *elem);
int snd_mixer_selem_is_enum_capture(snd_mixer_elem_t *elem);
int snd_mixer_selem_get_enum_items(snd_mixer_elem_t *elem);
int snd_mixer_selem_get_enum_item_name(snd_mixer_elem_t *elem, unsigned int idx, size_t maxlen, char *str);
int snd_mixer_selem_get_enum_item(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, unsigned int *idxp);
int snd_mixer_selem_set_enum_item(snd_mixer_elem_t *elem, snd_mixer_selem_channel_id_t channel, unsigned int idx);
size_t snd_mixer_selem_id_sizeof(void);
int snd_mixer_selem_id_malloc(snd_mixer_selem_id_t **ptr);
void snd_mixer_selem_id_free(snd_mixer_selem_id_t *obj);
void snd_mixer_selem_id_copy(snd_mixer_selem_id_t *dst, const snd_mixer_selem_id_t *src);
const char *snd_mixer_selem_id_get_name(const snd_mixer_selem_id_t *obj);
unsigned int snd_mixer_selem_id_get_index(const snd_mixer_selem_id_t *obj);
void snd_mixer_selem_id_set_name(snd_mixer_selem_id_t *obj, const char *val);
void snd_mixer_selem_id_set_index(snd_mixer_selem_id_t *obj, unsigned int val);

// /usr/include/alsa/seq_event.h
typedef unsigned char snd_seq_event_type_t;
enum snd_seq_event_type {
 SND_SEQ_EVENT_SYSTEM = 0,
 SND_SEQ_EVENT_RESULT,
 SND_SEQ_EVENT_NOTE = 5,
 SND_SEQ_EVENT_NOTEON,
 SND_SEQ_EVENT_NOTEOFF,
 SND_SEQ_EVENT_KEYPRESS,
 SND_SEQ_EVENT_CONTROLLER = 10,
 SND_SEQ_EVENT_PGMCHANGE,
 SND_SEQ_EVENT_CHANPRESS,
 SND_SEQ_EVENT_PITCHBEND,
 SND_SEQ_EVENT_CONTROL14,
 SND_SEQ_EVENT_NONREGPARAM,
 SND_SEQ_EVENT_REGPARAM,
 SND_SEQ_EVENT_SONGPOS = 20,
 SND_SEQ_EVENT_SONGSEL,
 SND_SEQ_EVENT_QFRAME,
 SND_SEQ_EVENT_TIMESIGN,
 SND_SEQ_EVENT_KEYSIGN,
 SND_SEQ_EVENT_START = 30,
 SND_SEQ_EVENT_CONTINUE,
 SND_SEQ_EVENT_STOP,
 SND_SEQ_EVENT_SETPOS_TICK,
 SND_SEQ_EVENT_SETPOS_TIME,
 SND_SEQ_EVENT_TEMPO,
 SND_SEQ_EVENT_CLOCK,
 SND_SEQ_EVENT_TICK,
 SND_SEQ_EVENT_QUEUE_SKEW,
 SND_SEQ_EVENT_SYNC_POS,
 SND_SEQ_EVENT_TUNE_REQUEST = 40,
 SND_SEQ_EVENT_RESET,
 SND_SEQ_EVENT_SENSING,
 SND_SEQ_EVENT_ECHO = 50,
 SND_SEQ_EVENT_OSS,
 SND_SEQ_EVENT_CLIENT_START = 60,
 SND_SEQ_EVENT_CLIENT_EXIT,
 SND_SEQ_EVENT_CLIENT_CHANGE,
 SND_SEQ_EVENT_PORT_START,
 SND_SEQ_EVENT_PORT_EXIT,
 SND_SEQ_EVENT_PORT_CHANGE,
 SND_SEQ_EVENT_PORT_SUBSCRIBED,
 SND_SEQ_EVENT_PORT_UNSUBSCRIBED,
 SND_SEQ_EVENT_USR0 = 90,
 SND_SEQ_EVENT_USR1,
 SND_SEQ_EVENT_USR2,
 SND_SEQ_EVENT_USR3,
 SND_SEQ_EVENT_USR4,
 SND_SEQ_EVENT_USR5,
 SND_SEQ_EVENT_USR6,
 SND_SEQ_EVENT_USR7,
 SND_SEQ_EVENT_USR8,
 SND_SEQ_EVENT_USR9,
 SND_SEQ_EVENT_SYSEX = 130,
 SND_SEQ_EVENT_BOUNCE,
 SND_SEQ_EVENT_USR_VAR0 = 135,
 SND_SEQ_EVENT_USR_VAR1,
 SND_SEQ_EVENT_USR_VAR2,
 SND_SEQ_EVENT_USR_VAR3,
 SND_SEQ_EVENT_USR_VAR4,
 SND_SEQ_EVENT_NONE = 255
};
typedef struct snd_seq_addr {
 unsigned char client;
 unsigned char port;
} snd_seq_addr_t;
typedef struct snd_seq_connect {
 snd_seq_addr_t sender;
 snd_seq_addr_t dest;
} snd_seq_connect_t;
typedef struct snd_seq_real_time {
 unsigned int tv_sec;
 unsigned int tv_nsec;
} snd_seq_real_time_t;
typedef unsigned int snd_seq_tick_time_t;
typedef union snd_seq_timestamp {
 snd_seq_tick_time_t tick;
 struct snd_seq_real_time time;
} snd_seq_timestamp_t;
enum {
	SND_SEQ_TIME_STAMP_TICK = (0<<0),
	SND_SEQ_TIME_STAMP_REAL = (1<<0),
	SND_SEQ_TIME_STAMP_MASK = (1<<0),
	SND_SEQ_TIME_MODE_ABS = (0<<1),
	SND_SEQ_TIME_MODE_REL = (1<<1),
	SND_SEQ_TIME_MODE_MASK = (1<<1),
	SND_SEQ_EVENT_LENGTH_FIXED = (0<<2),
	SND_SEQ_EVENT_LENGTH_VARIABLE = (1<<2),
	SND_SEQ_EVENT_LENGTH_VARUSR = (2<<2),
	SND_SEQ_EVENT_LENGTH_MASK = (3<<2),
	SND_SEQ_PRIORITY_NORMAL = (0<<4),
	SND_SEQ_PRIORITY_HIGH = (1<<4),
	SND_SEQ_PRIORITY_MASK = (1<<4),
};
typedef struct snd_seq_ev_note {
 unsigned char channel;
 unsigned char note;
 unsigned char velocity;
 unsigned char off_velocity;
 unsigned int duration;
} snd_seq_ev_note_t;
typedef struct snd_seq_ev_ctrl {
 unsigned char channel;
 unsigned char unused[3];
 unsigned int param;
 signed int value;
} snd_seq_ev_ctrl_t;
typedef struct snd_seq_ev_raw8 {
 unsigned char d[12];
} snd_seq_ev_raw8_t;
typedef struct snd_seq_ev_raw32 {
 unsigned int d[3];
} snd_seq_ev_raw32_t;
typedef struct snd_seq_ev_ext {
 unsigned int len;
 void *ptr;
} __attribute__((packed)) snd_seq_ev_ext_t;
typedef struct snd_seq_result {
 int event;
 int result;
} snd_seq_result_t;
typedef struct snd_seq_queue_skew {
 unsigned int value;
 unsigned int base;
} snd_seq_queue_skew_t;
typedef struct snd_seq_ev_queue_control {
 unsigned char queue;
 unsigned char unused[3];
 union {
  signed int value;
  snd_seq_timestamp_t time;
  unsigned int position;
  snd_seq_queue_skew_t skew;
  unsigned int d32[2];
  unsigned char d8[8];
 } param;
} snd_seq_ev_queue_control_t;
typedef struct snd_seq_event {
 snd_seq_event_type_t type;
 unsigned char flags;
 unsigned char tag;
 unsigned char queue;
 snd_seq_timestamp_t time;
 snd_seq_addr_t source;
 snd_seq_addr_t dest;
 union {
  snd_seq_ev_note_t note;
  snd_seq_ev_ctrl_t control;
  snd_seq_ev_raw8_t raw8;
  snd_seq_ev_raw32_t raw32;
  snd_seq_ev_ext_t ext;
  snd_seq_ev_queue_control_t queue;
  snd_seq_timestamp_t time;
  snd_seq_addr_t addr;
  snd_seq_connect_t connect;
  snd_seq_result_t result;
 } data;
} snd_seq_event_t;

// /usr/include/alsa/seq.h
typedef struct _snd_seq snd_seq_t;
enum {
	SND_SEQ_OPEN_OUTPUT  = 1,
	SND_SEQ_OPEN_INPUT   = 2,
	SND_SEQ_OPEN_DUPLEX  = (SND_SEQ_OPEN_OUTPUT|SND_SEQ_OPEN_INPUT),
	SND_SEQ_NONBLOCK     = 0x0001,
};
typedef enum _snd_seq_type {
 SND_SEQ_TYPE_HW,
 SND_SEQ_TYPE_SHM,
 SND_SEQ_TYPE_INET
} snd_seq_type_t;
enum {
	SND_SEQ_ADDRESS_UNKNOWN = 253,
	SND_SEQ_ADDRESS_SUBSCRIBERS = 254,
	SND_SEQ_ADDRESS_BROADCAST = 255,
	SND_SEQ_CLIENT_SYSTEM = 0,
};
int snd_seq_open(snd_seq_t **handle, const char *name, int streams, int mode);
int snd_seq_open_lconf(snd_seq_t **handle, const char *name, int streams, int mode, snd_config_t *lconf);
const char *snd_seq_name(snd_seq_t *seq);
snd_seq_type_t snd_seq_type(snd_seq_t *seq);
int snd_seq_close(snd_seq_t *handle);
int snd_seq_poll_descriptors_count(snd_seq_t *handle, short events);
int snd_seq_poll_descriptors(snd_seq_t *handle, struct pollfd *pfds, unsigned int space, short events);
int snd_seq_poll_descriptors_revents(snd_seq_t *seq, struct pollfd *pfds, unsigned int nfds, unsigned short *revents);
int snd_seq_nonblock(snd_seq_t *handle, int nonblock);
int snd_seq_client_id(snd_seq_t *handle);
size_t snd_seq_get_output_buffer_size(snd_seq_t *handle);
size_t snd_seq_get_input_buffer_size(snd_seq_t *handle);
int snd_seq_set_output_buffer_size(snd_seq_t *handle, size_t size);
int snd_seq_set_input_buffer_size(snd_seq_t *handle, size_t size);
typedef struct _snd_seq_system_info snd_seq_system_info_t;
size_t snd_seq_system_info_sizeof(void);
int snd_seq_system_info_malloc(snd_seq_system_info_t **ptr);
void snd_seq_system_info_free(snd_seq_system_info_t *ptr);
void snd_seq_system_info_copy(snd_seq_system_info_t *dst, const snd_seq_system_info_t *src);
int snd_seq_system_info_get_queues(const snd_seq_system_info_t *info);
int snd_seq_system_info_get_clients(const snd_seq_system_info_t *info);
int snd_seq_system_info_get_ports(const snd_seq_system_info_t *info);
int snd_seq_system_info_get_channels(const snd_seq_system_info_t *info);
int snd_seq_system_info_get_cur_clients(const snd_seq_system_info_t *info);
int snd_seq_system_info_get_cur_queues(const snd_seq_system_info_t *info);
int snd_seq_system_info(snd_seq_t *handle, snd_seq_system_info_t *info);
typedef struct _snd_seq_client_info snd_seq_client_info_t;
typedef enum snd_seq_client_type {
 SND_SEQ_USER_CLIENT = 1,
 SND_SEQ_KERNEL_CLIENT = 2
} snd_seq_client_type_t;
size_t snd_seq_client_info_sizeof(void);
int snd_seq_client_info_malloc(snd_seq_client_info_t **ptr);
void snd_seq_client_info_free(snd_seq_client_info_t *ptr);
void snd_seq_client_info_copy(snd_seq_client_info_t *dst, const snd_seq_client_info_t *src);
int snd_seq_client_info_get_client(const snd_seq_client_info_t *info);
snd_seq_client_type_t snd_seq_client_info_get_type(const snd_seq_client_info_t *info);
const char *snd_seq_client_info_get_name(snd_seq_client_info_t *info);
int snd_seq_client_info_get_broadcast_filter(const snd_seq_client_info_t *info);
int snd_seq_client_info_get_error_bounce(const snd_seq_client_info_t *info);
const unsigned char *snd_seq_client_info_get_event_filter(const snd_seq_client_info_t *info);
int snd_seq_client_info_get_num_ports(const snd_seq_client_info_t *info);
int snd_seq_client_info_get_event_lost(const snd_seq_client_info_t *info);
void snd_seq_client_info_set_client(snd_seq_client_info_t *info, int client);
void snd_seq_client_info_set_name(snd_seq_client_info_t *info, const char *name);
void snd_seq_client_info_set_broadcast_filter(snd_seq_client_info_t *info, int val);
void snd_seq_client_info_set_error_bounce(snd_seq_client_info_t *info, int val);
void snd_seq_client_info_set_event_filter(snd_seq_client_info_t *info, unsigned char *filter);
void snd_seq_client_info_event_filter_clear(snd_seq_client_info_t *info);
void snd_seq_client_info_event_filter_add(snd_seq_client_info_t *info, int event_type);
void snd_seq_client_info_event_filter_del(snd_seq_client_info_t *info, int event_type);
int snd_seq_client_info_event_filter_check(snd_seq_client_info_t *info, int event_type);
int snd_seq_get_client_info(snd_seq_t *handle, snd_seq_client_info_t *info);
int snd_seq_get_any_client_info(snd_seq_t *handle, int client, snd_seq_client_info_t *info);
int snd_seq_set_client_info(snd_seq_t *handle, snd_seq_client_info_t *info);
int snd_seq_query_next_client(snd_seq_t *handle, snd_seq_client_info_t *info);
typedef struct _snd_seq_client_pool snd_seq_client_pool_t;
size_t snd_seq_client_pool_sizeof(void);
int snd_seq_client_pool_malloc(snd_seq_client_pool_t **ptr);
void snd_seq_client_pool_free(snd_seq_client_pool_t *ptr);
void snd_seq_client_pool_copy(snd_seq_client_pool_t *dst, const snd_seq_client_pool_t *src);
int snd_seq_client_pool_get_client(const snd_seq_client_pool_t *info);
size_t snd_seq_client_pool_get_output_pool(const snd_seq_client_pool_t *info);
size_t snd_seq_client_pool_get_input_pool(const snd_seq_client_pool_t *info);
size_t snd_seq_client_pool_get_output_room(const snd_seq_client_pool_t *info);
size_t snd_seq_client_pool_get_output_free(const snd_seq_client_pool_t *info);
size_t snd_seq_client_pool_get_input_free(const snd_seq_client_pool_t *info);
void snd_seq_client_pool_set_output_pool(snd_seq_client_pool_t *info, size_t size);
void snd_seq_client_pool_set_input_pool(snd_seq_client_pool_t *info, size_t size);
void snd_seq_client_pool_set_output_room(snd_seq_client_pool_t *info, size_t size);
int snd_seq_get_client_pool(snd_seq_t *handle, snd_seq_client_pool_t *info);
int snd_seq_set_client_pool(snd_seq_t *handle, snd_seq_client_pool_t *info);
typedef struct _snd_seq_port_info snd_seq_port_info_t;
enum {
	SND_SEQ_PORT_SYSTEM_TIMER = 0,
	SND_SEQ_PORT_SYSTEM_ANNOUNCE = 1,
	SND_SEQ_PORT_CAP_READ = (1<<0),
	SND_SEQ_PORT_CAP_WRITE = (1<<1),
	SND_SEQ_PORT_CAP_SYNC_READ = (1<<2),
	SND_SEQ_PORT_CAP_SYNC_WRITE = (1<<3),
	SND_SEQ_PORT_CAP_DUPLEX = (1<<4),
	SND_SEQ_PORT_CAP_SUBS_READ = (1<<5),
	SND_SEQ_PORT_CAP_SUBS_WRITE = (1<<6),
	SND_SEQ_PORT_CAP_NO_EXPORT = (1<<7),
	SND_SEQ_PORT_TYPE_SPECIFIC = (1<<0),
	SND_SEQ_PORT_TYPE_MIDI_GENERIC = (1<<1),
	SND_SEQ_PORT_TYPE_MIDI_GM = (1<<2),
	SND_SEQ_PORT_TYPE_MIDI_GS = (1<<3),
	SND_SEQ_PORT_TYPE_MIDI_XG = (1<<4),
	SND_SEQ_PORT_TYPE_MIDI_MT32 = (1<<5),
	SND_SEQ_PORT_TYPE_MIDI_GM2 = (1<<6),
	SND_SEQ_PORT_TYPE_SYNTH = (1<<10),
	SND_SEQ_PORT_TYPE_DIRECT_SAMPLE = (1<<11),
	SND_SEQ_PORT_TYPE_SAMPLE = (1<<12),
	SND_SEQ_PORT_TYPE_HARDWARE = (1<<16),
	SND_SEQ_PORT_TYPE_SOFTWARE = (1<<17),
	SND_SEQ_PORT_TYPE_SYNTHESIZER = (1<<18),
	SND_SEQ_PORT_TYPE_PORT = (1<<19),
	SND_SEQ_PORT_TYPE_APPLICATION = (1<<20),
};
size_t snd_seq_port_info_sizeof(void);
int snd_seq_port_info_malloc(snd_seq_port_info_t **ptr);
void snd_seq_port_info_free(snd_seq_port_info_t *ptr);
void snd_seq_port_info_copy(snd_seq_port_info_t *dst, const snd_seq_port_info_t *src);
int snd_seq_port_info_get_client(const snd_seq_port_info_t *info);
int snd_seq_port_info_get_port(const snd_seq_port_info_t *info);
const snd_seq_addr_t *snd_seq_port_info_get_addr(const snd_seq_port_info_t *info);
const char *snd_seq_port_info_get_name(const snd_seq_port_info_t *info);
unsigned int snd_seq_port_info_get_capability(const snd_seq_port_info_t *info);
unsigned int snd_seq_port_info_get_type(const snd_seq_port_info_t *info);
int snd_seq_port_info_get_midi_channels(const snd_seq_port_info_t *info);
int snd_seq_port_info_get_midi_voices(const snd_seq_port_info_t *info);
int snd_seq_port_info_get_synth_voices(const snd_seq_port_info_t *info);
int snd_seq_port_info_get_read_use(const snd_seq_port_info_t *info);
int snd_seq_port_info_get_write_use(const snd_seq_port_info_t *info);
int snd_seq_port_info_get_port_specified(const snd_seq_port_info_t *info);
int snd_seq_port_info_get_timestamping(const snd_seq_port_info_t *info);
int snd_seq_port_info_get_timestamp_real(const snd_seq_port_info_t *info);
int snd_seq_port_info_get_timestamp_queue(const snd_seq_port_info_t *info);
void snd_seq_port_info_set_client(snd_seq_port_info_t *info, int client);
void snd_seq_port_info_set_port(snd_seq_port_info_t *info, int port);
void snd_seq_port_info_set_addr(snd_seq_port_info_t *info, const snd_seq_addr_t *addr);
void snd_seq_port_info_set_name(snd_seq_port_info_t *info, const char *name);
void snd_seq_port_info_set_capability(snd_seq_port_info_t *info, unsigned int capability);
void snd_seq_port_info_set_type(snd_seq_port_info_t *info, unsigned int type);
void snd_seq_port_info_set_midi_channels(snd_seq_port_info_t *info, int channels);
void snd_seq_port_info_set_midi_voices(snd_seq_port_info_t *info, int voices);
void snd_seq_port_info_set_synth_voices(snd_seq_port_info_t *info, int voices);
void snd_seq_port_info_set_port_specified(snd_seq_port_info_t *info, int val);
void snd_seq_port_info_set_timestamping(snd_seq_port_info_t *info, int enable);
void snd_seq_port_info_set_timestamp_real(snd_seq_port_info_t *info, int realtime);
void snd_seq_port_info_set_timestamp_queue(snd_seq_port_info_t *info, int queue);
int snd_seq_create_port(snd_seq_t *handle, snd_seq_port_info_t *info);
int snd_seq_delete_port(snd_seq_t *handle, int port);
int snd_seq_get_port_info(snd_seq_t *handle, int port, snd_seq_port_info_t *info);
int snd_seq_get_any_port_info(snd_seq_t *handle, int client, int port, snd_seq_port_info_t *info);
int snd_seq_set_port_info(snd_seq_t *handle, int port, snd_seq_port_info_t *info);
int snd_seq_query_next_port(snd_seq_t *handle, snd_seq_port_info_t *info);
typedef struct _snd_seq_port_subscribe snd_seq_port_subscribe_t;
size_t snd_seq_port_subscribe_sizeof(void);
int snd_seq_port_subscribe_malloc(snd_seq_port_subscribe_t **ptr);
void snd_seq_port_subscribe_free(snd_seq_port_subscribe_t *ptr);
void snd_seq_port_subscribe_copy(snd_seq_port_subscribe_t *dst, const snd_seq_port_subscribe_t *src);
const snd_seq_addr_t *snd_seq_port_subscribe_get_sender(const snd_seq_port_subscribe_t *info);
const snd_seq_addr_t *snd_seq_port_subscribe_get_dest(const snd_seq_port_subscribe_t *info);
int snd_seq_port_subscribe_get_queue(const snd_seq_port_subscribe_t *info);
int snd_seq_port_subscribe_get_exclusive(const snd_seq_port_subscribe_t *info);
int snd_seq_port_subscribe_get_time_update(const snd_seq_port_subscribe_t *info);
int snd_seq_port_subscribe_get_time_real(const snd_seq_port_subscribe_t *info);
void snd_seq_port_subscribe_set_sender(snd_seq_port_subscribe_t *info, const snd_seq_addr_t *addr);
void snd_seq_port_subscribe_set_dest(snd_seq_port_subscribe_t *info, const snd_seq_addr_t *addr);
void snd_seq_port_subscribe_set_queue(snd_seq_port_subscribe_t *info, int q);
void snd_seq_port_subscribe_set_exclusive(snd_seq_port_subscribe_t *info, int val);
void snd_seq_port_subscribe_set_time_update(snd_seq_port_subscribe_t *info, int val);
void snd_seq_port_subscribe_set_time_real(snd_seq_port_subscribe_t *info, int val);
int snd_seq_get_port_subscription(snd_seq_t *handle, snd_seq_port_subscribe_t *sub);
int snd_seq_subscribe_port(snd_seq_t *handle, snd_seq_port_subscribe_t *sub);
int snd_seq_unsubscribe_port(snd_seq_t *handle, snd_seq_port_subscribe_t *sub);
typedef struct _snd_seq_query_subscribe snd_seq_query_subscribe_t;
typedef enum {
 SND_SEQ_QUERY_SUBS_READ,
 SND_SEQ_QUERY_SUBS_WRITE
} snd_seq_query_subs_type_t;
size_t snd_seq_query_subscribe_sizeof(void);
int snd_seq_query_subscribe_malloc(snd_seq_query_subscribe_t **ptr);
void snd_seq_query_subscribe_free(snd_seq_query_subscribe_t *ptr);
void snd_seq_query_subscribe_copy(snd_seq_query_subscribe_t *dst, const snd_seq_query_subscribe_t *src);
int snd_seq_query_subscribe_get_client(const snd_seq_query_subscribe_t *info);
int snd_seq_query_subscribe_get_port(const snd_seq_query_subscribe_t *info);
const snd_seq_addr_t *snd_seq_query_subscribe_get_root(const snd_seq_query_subscribe_t *info);
snd_seq_query_subs_type_t snd_seq_query_subscribe_get_type(const snd_seq_query_subscribe_t *info);
int snd_seq_query_subscribe_get_index(const snd_seq_query_subscribe_t *info);
int snd_seq_query_subscribe_get_num_subs(const snd_seq_query_subscribe_t *info);
const snd_seq_addr_t *snd_seq_query_subscribe_get_addr(const snd_seq_query_subscribe_t *info);
int snd_seq_query_subscribe_get_queue(const snd_seq_query_subscribe_t *info);
int snd_seq_query_subscribe_get_exclusive(const snd_seq_query_subscribe_t *info);
int snd_seq_query_subscribe_get_time_update(const snd_seq_query_subscribe_t *info);
int snd_seq_query_subscribe_get_time_real(const snd_seq_query_subscribe_t *info);
void snd_seq_query_subscribe_set_client(snd_seq_query_subscribe_t *info, int client);
void snd_seq_query_subscribe_set_port(snd_seq_query_subscribe_t *info, int port);
void snd_seq_query_subscribe_set_root(snd_seq_query_subscribe_t *info, const snd_seq_addr_t *addr);
void snd_seq_query_subscribe_set_type(snd_seq_query_subscribe_t *info, snd_seq_query_subs_type_t type);
void snd_seq_query_subscribe_set_index(snd_seq_query_subscribe_t *info, int _index);
int snd_seq_query_port_subscribers(snd_seq_t *seq, snd_seq_query_subscribe_t * subs);
typedef struct _snd_seq_queue_info snd_seq_queue_info_t;
typedef struct _snd_seq_queue_status snd_seq_queue_status_t;
typedef struct _snd_seq_queue_tempo snd_seq_queue_tempo_t;
typedef struct _snd_seq_queue_timer snd_seq_queue_timer_t;
enum {
	SND_SEQ_QUEUE_DIRECT = 253,
};
size_t snd_seq_queue_info_sizeof(void);
int snd_seq_queue_info_malloc(snd_seq_queue_info_t **ptr);
void snd_seq_queue_info_free(snd_seq_queue_info_t *ptr);
void snd_seq_queue_info_copy(snd_seq_queue_info_t *dst, const snd_seq_queue_info_t *src);
int snd_seq_queue_info_get_queue(const snd_seq_queue_info_t *info);
const char *snd_seq_queue_info_get_name(const snd_seq_queue_info_t *info);
int snd_seq_queue_info_get_owner(const snd_seq_queue_info_t *info);
int snd_seq_queue_info_get_locked(const snd_seq_queue_info_t *info);
unsigned int snd_seq_queue_info_get_flags(const snd_seq_queue_info_t *info);
void snd_seq_queue_info_set_name(snd_seq_queue_info_t *info, const char *name);
void snd_seq_queue_info_set_owner(snd_seq_queue_info_t *info, int owner);
void snd_seq_queue_info_set_locked(snd_seq_queue_info_t *info, int locked);
void snd_seq_queue_info_set_flags(snd_seq_queue_info_t *info, unsigned int flags);
int snd_seq_create_queue(snd_seq_t *seq, snd_seq_queue_info_t *info);
int snd_seq_alloc_named_queue(snd_seq_t *seq, const char *name);
int snd_seq_alloc_queue(snd_seq_t *handle);
int snd_seq_free_queue(snd_seq_t *handle, int q);
int snd_seq_get_queue_info(snd_seq_t *seq, int q, snd_seq_queue_info_t *info);
int snd_seq_set_queue_info(snd_seq_t *seq, int q, snd_seq_queue_info_t *info);
int snd_seq_query_named_queue(snd_seq_t *seq, const char *name);
int snd_seq_get_queue_usage(snd_seq_t *handle, int q);
int snd_seq_set_queue_usage(snd_seq_t *handle, int q, int used);
size_t snd_seq_queue_status_sizeof(void);
int snd_seq_queue_status_malloc(snd_seq_queue_status_t **ptr);
void snd_seq_queue_status_free(snd_seq_queue_status_t *ptr);
void snd_seq_queue_status_copy(snd_seq_queue_status_t *dst, const snd_seq_queue_status_t *src);
int snd_seq_queue_status_get_queue(const snd_seq_queue_status_t *info);
int snd_seq_queue_status_get_events(const snd_seq_queue_status_t *info);
snd_seq_tick_time_t snd_seq_queue_status_get_tick_time(const snd_seq_queue_status_t *info);
const snd_seq_real_time_t *snd_seq_queue_status_get_real_time(const snd_seq_queue_status_t *info);
unsigned int snd_seq_queue_status_get_status(const snd_seq_queue_status_t *info);
int snd_seq_get_queue_status(snd_seq_t *handle, int q, snd_seq_queue_status_t *status);
size_t snd_seq_queue_tempo_sizeof(void);
int snd_seq_queue_tempo_malloc(snd_seq_queue_tempo_t **ptr);
void snd_seq_queue_tempo_free(snd_seq_queue_tempo_t *ptr);
void snd_seq_queue_tempo_copy(snd_seq_queue_tempo_t *dst, const snd_seq_queue_tempo_t *src);
int snd_seq_queue_tempo_get_queue(const snd_seq_queue_tempo_t *info);
unsigned int snd_seq_queue_tempo_get_tempo(const snd_seq_queue_tempo_t *info);
int snd_seq_queue_tempo_get_ppq(const snd_seq_queue_tempo_t *info);
unsigned int snd_seq_queue_tempo_get_skew(const snd_seq_queue_tempo_t *info);
unsigned int snd_seq_queue_tempo_get_skew_base(const snd_seq_queue_tempo_t *info);
void snd_seq_queue_tempo_set_tempo(snd_seq_queue_tempo_t *info, unsigned int tempo);
void snd_seq_queue_tempo_set_ppq(snd_seq_queue_tempo_t *info, int ppq);
void snd_seq_queue_tempo_set_skew(snd_seq_queue_tempo_t *info, unsigned int skew);
void snd_seq_queue_tempo_set_skew_base(snd_seq_queue_tempo_t *info, unsigned int base);
int snd_seq_get_queue_tempo(snd_seq_t *handle, int q, snd_seq_queue_tempo_t *tempo);
int snd_seq_set_queue_tempo(snd_seq_t *handle, int q, snd_seq_queue_tempo_t *tempo);
typedef enum {
 SND_SEQ_TIMER_ALSA = 0,
 SND_SEQ_TIMER_MIDI_CLOCK = 1,
 SND_SEQ_TIMER_MIDI_TICK = 2
} snd_seq_queue_timer_type_t;
size_t snd_seq_queue_timer_sizeof(void);
int snd_seq_queue_timer_malloc(snd_seq_queue_timer_t **ptr);
void snd_seq_queue_timer_free(snd_seq_queue_timer_t *ptr);
void snd_seq_queue_timer_copy(snd_seq_queue_timer_t *dst, const snd_seq_queue_timer_t *src);
int snd_seq_queue_timer_get_queue(const snd_seq_queue_timer_t *info);
snd_seq_queue_timer_type_t snd_seq_queue_timer_get_type(const snd_seq_queue_timer_t *info);
const snd_timer_id_t *snd_seq_queue_timer_get_id(const snd_seq_queue_timer_t *info);
unsigned int snd_seq_queue_timer_get_resolution(const snd_seq_queue_timer_t *info);
void snd_seq_queue_timer_set_type(snd_seq_queue_timer_t *info, snd_seq_queue_timer_type_t type);
void snd_seq_queue_timer_set_id(snd_seq_queue_timer_t *info, const snd_timer_id_t *id);
void snd_seq_queue_timer_set_resolution(snd_seq_queue_timer_t *info, unsigned int resolution);
int snd_seq_get_queue_timer(snd_seq_t *handle, int q, snd_seq_queue_timer_t *timer);
int snd_seq_set_queue_timer(snd_seq_t *handle, int q, snd_seq_queue_timer_t *timer);
int snd_seq_free_event(snd_seq_event_t *ev);
ssize_t snd_seq_event_length(snd_seq_event_t *ev);
int snd_seq_event_output(snd_seq_t *handle, snd_seq_event_t *ev);
int snd_seq_event_output_buffer(snd_seq_t *handle, snd_seq_event_t *ev);
int snd_seq_event_output_direct(snd_seq_t *handle, snd_seq_event_t *ev);
int snd_seq_event_input(snd_seq_t *handle, snd_seq_event_t **ev);
int snd_seq_event_input_pending(snd_seq_t *seq, int fetch_sequencer);
int snd_seq_drain_output(snd_seq_t *handle);
int snd_seq_event_output_pending(snd_seq_t *seq);
int snd_seq_extract_output(snd_seq_t *handle, snd_seq_event_t **ev);
int snd_seq_drop_output(snd_seq_t *handle);
int snd_seq_drop_output_buffer(snd_seq_t *handle);
int snd_seq_drop_input(snd_seq_t *handle);
int snd_seq_drop_input_buffer(snd_seq_t *handle);
typedef struct _snd_seq_remove_events snd_seq_remove_events_t;
enum {
	SND_SEQ_REMOVE_INPUT = (1<<0),
	SND_SEQ_REMOVE_OUTPUT = (1<<1),
	SND_SEQ_REMOVE_DEST  = (1<<2),
	SND_SEQ_REMOVE_DEST_CHANNEL = (1<<3),
	SND_SEQ_REMOVE_TIME_BEFORE = (1<<4),
	SND_SEQ_REMOVE_TIME_AFTER = (1<<5),
	SND_SEQ_REMOVE_TIME_TICK = (1<<6),
	SND_SEQ_REMOVE_EVENT_TYPE = (1<<7),
	SND_SEQ_REMOVE_IGNORE_OFF = (1<<8),
	SND_SEQ_REMOVE_TAG_MATCH = (1<<9),
};
size_t snd_seq_remove_events_sizeof(void);
int snd_seq_remove_events_malloc(snd_seq_remove_events_t **ptr);
void snd_seq_remove_events_free(snd_seq_remove_events_t *ptr);
void snd_seq_remove_events_copy(snd_seq_remove_events_t *dst, const snd_seq_remove_events_t *src);
unsigned int snd_seq_remove_events_get_condition(const snd_seq_remove_events_t *info);
int snd_seq_remove_events_get_queue(const snd_seq_remove_events_t *info);
const snd_seq_timestamp_t *snd_seq_remove_events_get_time(const snd_seq_remove_events_t *info);
const snd_seq_addr_t *snd_seq_remove_events_get_dest(const snd_seq_remove_events_t *info);
int snd_seq_remove_events_get_channel(const snd_seq_remove_events_t *info);
int snd_seq_remove_events_get_event_type(const snd_seq_remove_events_t *info);
int snd_seq_remove_events_get_tag(const snd_seq_remove_events_t *info);
void snd_seq_remove_events_set_condition(snd_seq_remove_events_t *info, unsigned int flags);
void snd_seq_remove_events_set_queue(snd_seq_remove_events_t *info, int queue);
void snd_seq_remove_events_set_time(snd_seq_remove_events_t *info, const snd_seq_timestamp_t *time);
void snd_seq_remove_events_set_dest(snd_seq_remove_events_t *info, const snd_seq_addr_t *addr);
void snd_seq_remove_events_set_channel(snd_seq_remove_events_t *info, int channel);
void snd_seq_remove_events_set_event_type(snd_seq_remove_events_t *info, int type);
void snd_seq_remove_events_set_tag(snd_seq_remove_events_t *info, int tag);
int snd_seq_remove_events(snd_seq_t *handle, snd_seq_remove_events_t *info);
void snd_seq_set_bit(int nr, void *array);
void snd_seq_unset_bit(int nr, void *array);
int snd_seq_change_bit(int nr, void *array);
int snd_seq_get_bit(int nr, void *array);
enum {
 SND_SEQ_EVFLG_RESULT,
 SND_SEQ_EVFLG_NOTE,
 SND_SEQ_EVFLG_CONTROL,
 SND_SEQ_EVFLG_QUEUE,
 SND_SEQ_EVFLG_SYSTEM,
 SND_SEQ_EVFLG_MESSAGE,
 SND_SEQ_EVFLG_CONNECTION,
 SND_SEQ_EVFLG_SAMPLE,
 SND_SEQ_EVFLG_USERS,
 SND_SEQ_EVFLG_INSTR,
 SND_SEQ_EVFLG_QUOTE,
 SND_SEQ_EVFLG_NONE,
 SND_SEQ_EVFLG_RAW,
 SND_SEQ_EVFLG_FIXED,
 SND_SEQ_EVFLG_VARIABLE,
 SND_SEQ_EVFLG_VARUSR
};
enum {
 SND_SEQ_EVFLG_NOTE_ONEARG,
 SND_SEQ_EVFLG_NOTE_TWOARG
};
enum {
 SND_SEQ_EVFLG_QUEUE_NOARG,
 SND_SEQ_EVFLG_QUEUE_TICK,
 SND_SEQ_EVFLG_QUEUE_TIME,
 SND_SEQ_EVFLG_QUEUE_VALUE
};
extern const unsigned int snd_seq_event_types[];

int snd_seq_create_simple_port(snd_seq_t *seq, const char *name,
          unsigned int caps, unsigned int type);
int snd_seq_delete_simple_port(snd_seq_t *seq, int port);
int snd_seq_connect_from(snd_seq_t *seq, int my_port, int src_client, int src_port);
int snd_seq_connect_to(snd_seq_t *seq, int my_port, int dest_client, int dest_port);
int snd_seq_disconnect_from(snd_seq_t *seq, int my_port, int src_client, int src_port);
int snd_seq_disconnect_to(snd_seq_t *seq, int my_port, int dest_client, int dest_port);
int snd_seq_set_client_name(snd_seq_t *seq, const char *name);
int snd_seq_set_client_event_filter(snd_seq_t *seq, int event_type);
int snd_seq_set_client_pool_output(snd_seq_t *seq, size_t size);
int snd_seq_set_client_pool_output_room(snd_seq_t *seq, size_t size);
int snd_seq_set_client_pool_input(snd_seq_t *seq, size_t size);
int snd_seq_sync_output_queue(snd_seq_t *seq);
int snd_seq_parse_address(snd_seq_t *seq, snd_seq_addr_t *addr, const char *str);
int snd_seq_reset_pool_output(snd_seq_t *seq);
int snd_seq_reset_pool_input(snd_seq_t *seq);
snd_seq_ev_set_fixed(ev), (ev)->data.note.channel = (ch), (ev)->data.note.note = (key), (ev)->data.note.velocity = (vel), (ev)->data.note.duration = (dur))
snd_seq_ev_set_fixed(ev), (ev)->data.note.channel = (ch), (ev)->data.note.note = (key), (ev)->data.note.velocity = (vel))

// /usr/include/alsa/seq_midi_event.h
typedef struct snd_midi_event snd_midi_event_t;
int snd_midi_event_new(size_t bufsize, snd_midi_event_t **rdev);
int snd_midi_event_resize_buffer(snd_midi_event_t *dev, size_t bufsize);
void snd_midi_event_free(snd_midi_event_t *dev);
void snd_midi_event_init(snd_midi_event_t *dev);
void snd_midi_event_reset_encode(snd_midi_event_t *dev);
void snd_midi_event_reset_decode(snd_midi_event_t *dev);
void snd_midi_event_no_status(snd_midi_event_t *dev, int on);
long snd_midi_event_encode(snd_midi_event_t *dev, const unsigned char *buf, long count, snd_seq_event_t *ev);
int snd_midi_event_encode_byte(snd_midi_event_t *dev, int c, snd_seq_event_t *ev);
long snd_midi_event_decode(snd_midi_event_t *dev, unsigned char *buf, long count, const snd_seq_event_t *ev);
]]
