#include <iostream>
#include <openssl/conf.h>
#include <openssl/evp.h>
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/err.h>

#define OUT_LEN 1024

int main(){
    ERR_load_crypto_strings();
    OpenSSL_add_all_algorithms();
    //OPENSSL_config(NULL);
    
    const char* text = "Kecske ment a kis kertbe";
    
    EVP_PKEY* key = EVP_RSA_gen(1024);
    PEM_write_PUBKEY(stdout, key);
    PEM_write_PrivateKey(stdout, key, NULL, NULL, 0, NULL, NULL);
    EVP_PKEY_CTX* ctx = EVP_PKEY_CTX_new(key, NULL);
    
    EVP_PKEY_encrypt_init(ctx);
    
    unsigned char out[OUT_LEN];
    size_t written_len = OUT_LEN;
    
    int err = EVP_PKEY_encrypt(ctx, out, &written_len, (unsigned char*) text, strlen(text));
    
    std::cout << err << std::endl;
    std::cout << "Text to be encrypted: " << text << std::endl;
    std::cout << "Encrypted len: " << written_len << std::endl;
    
    EVP_PKEY_decrypt_init(ctx);
    
    unsigned char out_decrypted[OUT_LEN];
    memset(out_decrypted, 0, OUT_LEN);
    size_t decrypt_len = OUT_LEN;
    
    err = EVP_PKEY_decrypt(ctx, out_decrypted, &decrypt_len, out, written_len);
    
    std::cout << err << std::endl;
    std::cout << "Decrypted len: "  << decrypt_len << std::endl;
    std::cout << "Decrypted text: " << out_decrypted << std::endl;
    
    EVP_cleanup();
    CRYPTO_cleanup_all_ex_data();
    ERR_free_strings();

    return 0;
}





