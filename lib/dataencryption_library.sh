data_encryption_function() {
    ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

    cat >encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

    ## copy encryption-config.yaml to controller nodes
    gcloud compute scp encryption-config.yaml controller-0:~/

}
