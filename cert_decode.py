import base64
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

# The private key data in base64-encoded format
private_key_data = "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC7+oCwBAs/3XYX0A4+aHKmvAs9JuSuY9MSyswIYB2MKBpPihJEVMIPneZwob0X2MiSBG6Ry3GbpCs/lanxyyZ+clEn2a+y+Ycfpop8TrODNhXdtaoufhJH02Pc+hcrRK/W7p0T7hJE1o17/+DtkT7BnEFFItEUYrK0cGWuN3VPdHziWIsmUK8WZu9HUaV4otXL1WLpalhC6VRe8YnKIDa2GR41V6CzOtbUbYq0+NqnWtjylaKBIvzcME+Z1c3AmAILwTe80r6wPzL7CcKv9ZA0H3Sxj7vt6FL2BP0ST2X7mPqzeCmTfyktiFoiTeLFIgpEhBoz/3uRKSdzVW379ToFAgMBAAECggEAUFGsW8kWj27Oj0UwWN0jI/gUK0hrjNINdamePXPoHCNkfpjlzjmTA745oOWS2NYheTaYkgYmIFUov43w4+YkKAIriAX9C1GQOWddI9ky3b0l4apGMYBfyj3aHSjk7nF2WrVw+3uNZclxAcsm7gtSD8L2ppZGVNoJNo0R/TsoDk7ht9oYbspPcpa9DoB+LwZFtwvTNR0Uhy6s5Bob0Hdj5E9eX/Zx5LbD7EYlSgzRScO3yh5lP0aKot7dVRPWn6oEYn54ZkPIJuYrzquu03dOlNqZYwJkHuAKR1oU9Bp03/uPSiHiEiGdEHTAEgzJxjRupbeq20SX0F7/htFMVVu6XwKBgQDcb5QZXZBNRgLq/Dc1hZ+MCeJuJ7Xf2ufC/SMjy2Cu7+jg8UDy1R9fwWLNaejMR36DxxixrKQm6RW9bKXf2M79ixKDUiFMq3HJtK8fO8xqPfKBD/7SlFi6H8XDwfSNgekBQ6RC6a2Hor0W1UJAxZ5dbjd/j9xHSjWNgfPgp2TdXwKBgQDaTl/lz7quCpGl30bqjGcpqDDkHmOP3e6Y9VFRWgi9uooCBcOuDbaH+3NGBRDSLGG8yF5MP7hFe7tJRhowDXjVEa+IeAVE/0OQznOjLsV8Y5X8qZcZeJsXe4p5SvK7Tuc7HuHteVrwKJQDQhqMtf8qzKIatUGmqaaYI5c7ldi/GwKBgQDRrCwhiHaWmc5yt17IQQaGTGydPJZpjC3Asck35d5b54UKWU/e6stB6I9TNbcif6qeK8WYUs98114/ZFXOusoALsV4NanI5JaCNqQQQG/qamv9STqoEETpHQmebyFvbC82baGTp/PQPQJA8q5nL9G3qvuNEUiEYtjXddGEUZTGXwKBgQC5azgoiXeVu4RZznr9XKOCzkg4eVc3KtktMbAP2NjzzSzK6vp5K0yN0xTltAfFe8zH+6ecO8LXwXAhnFlB1y96Sbs9vjM7l1Rb+f5d66vxKuSJ5cFg8P9JwrSqsO3aCfp8TI64lQqYUN7mpY7HVQ2V3JkS9kD8vbuyHQimo2+lYQKBgQCLQTxY22SDWeO7nkSoVnc2Dq2z+XKqB/BjeaU3B0GWiREDvK4W30dk2plKPO6ORSvn9Gg/1vT5hy6UmNpJbKyk1xIzw71c7dK3IKeX25NUcMvVtbibSKqz1j8HEn/K2rR8goeYN01qUwQ/1BwemXXu6aXxWQ/LjQl0dcDTBeFrbQ==\n"

# Decode base64 and convert to bytes
private_key_bytes = base64.b64decode(private_key_data)

try:
    # Try to load the private key without a password
    private_key = serialization.load_der_private_key(private_key_bytes, password=None, backend=default_backend())
    print("Private key loaded successfully (no password)")
    
    # Print the private key if it's not password-protected
    if private_key:
        print(private_key)
except ValueError as e:
    print("Private key is password-protected:", e)
