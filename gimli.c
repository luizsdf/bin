/* assert(sizeof(int) == 4); */

static unsigned int rotate(unsigned int x, int bits) {
    return (x << bits) | (x >> (32 - bits));
}

static unsigned int load(const unsigned char *state, int pos) {
    unsigned int x;
    x = state[4 * pos + 3];
    x <<= 8;
    x |= state[4 * pos + 2];
    x <<= 8;
    x |= state[4 * pos + 1];
    x <<= 8;
    x |= state[4 * pos + 0];
    return x;
}

static void store(unsigned char *state, int pos, unsigned int x) {
    state[4 * pos + 0] = x;
    x >>= 8;
    state[4 * pos + 1] = x;
    x >>= 8;
    state[4 * pos + 2] = x;
    x >>= 8;
    state[4 * pos + 3] = x;
}

static void gimli(unsigned char state[48]) {
    int round, column;
    unsigned int x, y, z;

    for (round = 24; round > 0; round--) {
        for (column = 0; column < 4; column++) {
            x = rotate(load(state, column), 24);
            y = rotate(load(state, column + 4), 9);
            z = load(state, column + 8);
            store(state, column + 8, x ^ (z << 1) ^ ((y & z) << 2));
            store(state, column + 4, y ^ x ^ ((x | z) << 1));
            store(state, column, z ^ y ^ ((x & y) << 3));
        }

        if ((round & 3) == 0) {
            x = load(state, 0);
            store(state, 0, load(state, 1) ^ (0x9e377900 | round));
            store(state, 1, x);
            x = load(state, 2);
            store(state, 2, load(state, 3));
            store(state, 3, x);
        } else if ((round & 3) == 2) {
            x = load(state, 0);
            store(state, 0, load(state, 2));
            store(state, 2, x);
            x = load(state, 1);
            store(state, 1, load(state, 3));
            store(state, 3, x);
        }
    }
}

void gimli_hash(unsigned char digest[32], const unsigned char *message,
    long unsigned int message_size) {
    long unsigned int i;
    unsigned char state[48];

    for (i = 0; i < 48; i++) state[i] = 0;

    while (message_size >= 16) {
        for (i = 0; i < 16; i++) state[i] ^= message[i];
        gimli(state);
        message += 16;
        message_size -= 16;
    }
    for (i = 0; i < message_size; i++) state[i] ^= message[i];
    state[message_size] ^= 1;
    state[47] ^= 1;
    gimli(state);

    for (i = 0; i < 16; i++) digest[i] = state[i];
    gimli(state);
    digest += 16;
    for (i = 0; i < 16; i++) digest[i] = state[i];
}

void gimli_encrypt(unsigned char tag[16], unsigned char *ciphertext,
    const unsigned char *plaintext, long unsigned int text_size,
    const unsigned char *ad, long unsigned int ad_size,
    const unsigned char nonce[16], const unsigned char key[32]) {
    long unsigned int i;
    unsigned char state[48];

    for (i = 0; i < 16; i++) state[i] = nonce[i];
    for (i = 0; i < 32; i++) state[i + 16] = key[i];
    gimli(state);

    while (ad_size >= 16) {
        for (i = 0; i < 16; i++) state[i] ^= ad[i];
        gimli(state);
        ad += 16;
        ad_size -= 16;
    }
    for (i = 0; i < ad_size; i++) state[i] ^= ad[i];
    state[ad_size] ^= 1;
    state[47] ^= 1;
    gimli(state);

    while (text_size >= 16) {
        for (i = 0; i < 16; i++) ciphertext[i] = state[i] ^= plaintext[i];
        gimli(state);
        ciphertext += 16;
        plaintext += 16;
        text_size -= 16;
    }
    for (i = 0; i < text_size; i++) ciphertext[i] = state[i] ^= plaintext[i];
    state[text_size] ^= 1;
    state[47] ^= 1;
    gimli(state);

    for(i = 0; i < 16; i++) tag[i] = state[i];
}

int gimli_decrypt(const unsigned char tag[16], const unsigned char *ciphertext,
    unsigned char *plaintext, long unsigned int text_size,
    const unsigned char *ad, long unsigned int ad_size,
    const unsigned char nonce[16], const unsigned char key[32]) {
    int result;
    long unsigned int i;
    unsigned char state[48];

    for (i = 0; i < 16; i++) state[i] = nonce[i];
    for (i = 0; i < 32; i++) state[i + 16] = key[i];
    gimli(state);

    while (ad_size >= 16) {
        for (i = 0; i < 16; i++) state[i] ^= ad[i];
        gimli(state);
        ad += 16;
        ad_size -= 16;
    }
    for (i = 0; i < ad_size; i++) state[i] ^= ad[i];
    state[ad_size] ^= 1;
    state[47] ^= 1;
    gimli(state);

    while (text_size >= 16) {
        for (i = 0; i < 16; i++) plaintext[i] = state[i] ^ ciphertext[i];
        for (i = 0; i < 16; i++) state[i] ^= plaintext[i];
        gimli(state);
        ciphertext += 16;
        plaintext += 16;
        text_size -= 16;
    }
    for (i = 0; i < text_size; i++) plaintext[i] = state[i] ^ ciphertext[i];
    for (i = 0; i < text_size; i++) state[i] ^= plaintext[i];
    state[text_size] ^= 1;
    state[47] ^= 1;
    gimli(state);

    result = 0;
    for (i = 0; i < 16; i++) result |= tag[i] ^ state[i];
    return result;
}
