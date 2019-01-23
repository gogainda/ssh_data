#!/bin/bash

ssh-keygen -trsa -N "" -f ./rsa_ca
ssh-keygen -tdsa -N "" -f ./dsa_ca
ssh-keygen -tecdsa -N "" -f ./ecdsa_ca
ssh-keygen -ted25519 -N "" -f ./ed25519_ca

ssh-keygen -trsa -N "" -f ./rsa_leaf_for_rsa_ca
ssh-keygen -s rsa_ca -z 123 -n my-principal -I my-ident -O critical:foo=bar -O extension:baz=qwer -O clear rsa_leaf_for_rsa_ca.pub

ssh-keygen -trsa -N "" -f ./rsa_leaf_for_dsa_ca
ssh-keygen -s dsa_ca -z 123 -n my-principal -I my-ident -O critical:foo=bar -O extension:baz=qwer -O clear rsa_leaf_for_dsa_ca.pub

ssh-keygen -trsa -N "" -f ./rsa_leaf_for_ecdsa_ca
ssh-keygen -s ecdsa_ca -z 123 -n my-principal -I my-ident -O critical:foo=bar -O extension:baz=qwer -O clear rsa_leaf_for_ecdsa_ca.pub

ssh-keygen -trsa -N "" -f ./rsa_leaf_for_ed25519_ca
ssh-keygen -s ed25519_ca -z 123 -n my-principal -I my-ident -O critical:foo=bar -O extension:baz=qwer -O clear rsa_leaf_for_ed25519_ca.pub

ssh-keygen -tdsa -N "" -f ./dsa_leaf_for_rsa_ca
ssh-keygen -s rsa_ca -z 123 -n my-principal -I my-ident -O critical:foo=bar -O extension:baz=qwer -O clear dsa_leaf_for_rsa_ca.pub

ssh-keygen -tecdsa -N "" -f ./ecdsa_leaf_for_rsa_ca
ssh-keygen -s rsa_ca -z 123 -n my-principal -I my-ident -O critical:foo=bar -O extension:baz=qwer -O clear ecdsa_leaf_for_rsa_ca.pub

ssh-keygen -ted25519 -N "" -f ./ed25519_leaf_for_rsa_ca
ssh-keygen -s rsa_ca -z 123 -n my-principal -I my-ident -O critical:foo=bar -O extension:baz=qwer -O clear ed25519_leaf_for_rsa_ca.pub

# Create a certificate with a bad signature. We use ed25519 because the
# signature doesn't have any fancy encoding (Eg. RSA has PKCS1v1.5 and DSA/ECDSA
# have ASN.1).
ruby <<RUBY
require "base64"

encoded = File.read("rsa_leaf_for_ed25519_ca-cert.pub")
algo, b64, host = encoded.split(" ", 3)
raw = Base64.decode64(b64)

# we flip bits in the last byte, since that's where the signature is.
raw[-1] = (raw[-1].ord ^ 0xff).chr

b64 = Base64.strict_encode64(raw)
encoded = [algo, b64, host].join(" ")

File.open("bad_signature-cert.pub", "w") { |f| f.write(encoded) }
RUBY
