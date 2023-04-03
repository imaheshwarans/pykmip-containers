import ssl
import os
import sys
import shutil
import os.path
from os import path
from kmip.pie.client import ProxyKmipClient, enums
from kmip.pie import objects
from kmip.pie import client
from kmip import enums
from subprocess import call
from subprocess import getoutput

KMIP_IP = '127.0.0.1'
SERVER_PORT = '5696'
CERT_PATH = '/etc/pykmip/client_certificate.pem'
KEY_PATH = '/etc/pykmip/client_key.pem'
KEY_BITS=3072
CA_PATH = '/etc/pykmip/root_certificate.pem'
TEMP_DIRECTORY = 'temp'
KEY_HEX_OUTPUT= TEMP_DIRECTORY + '/' + 'key_output.txt'


def AsymmetricKeyRSA():

    c = ProxyKmipClient(hostname=KMIP_IP,port=SERVER_PORT,cert=CERT_PATH,key=KEY_PATH,ca=CA_PATH)
    print("Asymmetric Key Creation")
    with c:
        key_id = c.create_key_pair(
            enums.CryptographicAlgorithm.RSA,
            KEY_BITS,
            public_usage_mask=[
                enums.CryptographicUsageMask.ENCRYPT
            ],
            private_usage_mask=[
                enums.CryptographicUsageMask.DECRYPT
            ]
        )  
        
        print("Private Key ID : " +key_id[1])

        current_directory = os.getcwd()
        temp_directory = os.path.join(current_directory,TEMP_DIRECTORY)
        if not os.path.exists(temp_directory):
            os.makedirs(temp_directory)

        orig_stdout = sys.stdout
        f = open(KEY_HEX_OUTPUT, 'w')
        sys.stdout = f
        print(c.get(key_id[1]))
        sys.stdout = orig_stdout
        f.close()


def main():
    AsymmetricKeyRSA()

if __name__ == "__main__":
    if len(sys.argv) > 1:
         KEY_BITS=int(sys.argv[1])
         if KEY_BITS != 2048 and KEY_BITS !=3072 and KEY_BITS !=4096 and KEY_BITS != 7680:
             print("Invalid Key Bit provided: Please provide valid key bits 2048, 3072, 4096, 7680")
             exit(1)
         print("KEY BITS: ", KEY_BITS)
    main()
