#include <stdint.h>

#define ROTR32(x, b) (((x) >> (b)) | ((x) << (32 - (b))))
#define SWAP(s, u, v) t = (s)[u], (s)[u] = (s)[v], (s)[v] = t

void xoodoo(uint32_t state[12])
{
    uint32_t e[4], a, b, c, t, r, i;
    const uint32_t k[12] = { 0x058, 0x038, 0x3C0, 0x0D0, 0x120, 0x014,
                             0x060, 0x02C, 0x380, 0x0F0, 0x1A0, 0x012 };

    for (r = 0; r < 12; r++) {
        for (i = 0; i < 4; i++) {
            e[i] = ROTR32(state[i] ^ state[i + 4] ^ state[i + 8], 18);
            e[i] ^= ROTR32(e[i], 9);
        }
        for (i = 0; i < 12; i++) state[i] ^= e[(i - 1) & 3];
        SWAP(state, 7, 4);
        SWAP(state, 7, 5);
        SWAP(state, 7, 6);
        state[0] ^= k[r];
        for (i = 0; i < 4; i++) {
            a = state[i];
            b = state[i + 4];
            c = ROTR32(state[i + 8], 21);
            state[i + 8] = ROTR32((b & ~a) ^ c, 24);
            state[i + 4] = ROTR32((a & ~c) ^ b, 31);
            state[i] ^= c & ~b;
        }
        SWAP(state, 8, 10);
        SWAP(state, 9, 11);
    }
}

void absorb(uint32_t state[12], const uint8_t *message, uint64_t size)
{
    uint8_t *st = (uint8_t *) state;
    uint64_t i;

    while (size >= 16) {
        for (i = 0; i < 16; i++) st[i] ^= message[i];
        xoodoo(state);
        message += 16;
        size -= 16;
    }
    for (i = 0; i < size; i++) st[i] ^= message[i];
    st[size] ^= 0x1F;
    st[15] ^= 0x80;
    xoodoo(state);
}

void squeeze(uint32_t state[12], uint8_t *digest, uint64_t size)
{
    uint8_t *st = (uint8_t *) state;
    uint64_t i;

    while (size >= 16) {
        for (i = 0; i < 16; i++) digest[i] = st[i];
        xoodoo(state);
        digest += 16;
        size -= 16;
    }
    if (size > 0) {
        for (i = 0; i < size; i++) digest[i] = st[i];
        xoodoo(state);
    }
}

#include <stdio.h>
#include <string.h>

int main()
{
    size_t size, i;
    FILE *tty = fopen("/dev/tty", "r+");
    uint32_t state[12] = { 0 };
    char buffer[512] = { 0 };

    if (!tty) return 1;

    fprintf(tty, "Key: ");
    fgets(buffer, sizeof(buffer), tty);
    buffer[strcspn(buffer, "\n")] = 0;
    fprintf(tty, "Nonce: ");
    fgets(buffer + strlen(buffer), sizeof(buffer), tty);
    buffer[strcspn(buffer, "\n")] = 0;
    absorb(state, (uint8_t *) buffer, strlen(buffer));
    memset(buffer, 0, sizeof(buffer));

    while ((size = fread(buffer, 1, sizeof(buffer) / 2, stdin))) {
        squeeze(state, (uint8_t *) buffer + sizeof(buffer) / 2, size);
        for (i = 0; i < size; i++) buffer[i] ^= buffer[sizeof(buffer) / 2 + i];
        fwrite(buffer, 1, size, stdout);
    }

    fclose(tty);
    return 0;
}
