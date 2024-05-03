import socket
import openai
import unicodedata

openai.api_key = "sk-proj-WuoXT5lUp3mNnsckReEnT3BlbkFJx8sphbgdtHgKpH1C85a2"

def remove_accents(input_str_):
    nfkd_form = unicodedata.normalize('NFKD', input_str_)
    return u"".join([c for c in nfkd_form if not unicodedata.combining(c)])

s = socket.socket()
print('Socket created')
s.bind(('localhost', 9999))
s.listen(1)
print('Waiting for connection...')

chat_history = []

try:
    while True:
        c, addr = s.accept()
        
        data = c.recv(1024)  # Receive data from client

        prompt = data.decode('utf-8')  # Decode bytes to string with UTF-8
        prompt = remove_accents(prompt)  # Remove accents from the prompt


        if prompt == "exit":
            break

        chat_history.append({"role": "user", "content": prompt})

        response_iterator = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=chat_history,
            stream=True,
            max_tokens=600,
        )

        collected_messages = []

        for chunk in response_iterator:
            chunk_message = chunk['choices'][0]['delta']  # Extract the message
            collected_messages.append(chunk_message)  # Save the message
            full_reply_content = ''.join([m.get('content', '') for m in collected_messages])

        # Apply remove_accents function before sending response
        full_reply_content = remove_accents(full_reply_content)
        # Send response back to the client after the completion of the response
        c.sendall(full_reply_content.encode('utf-8'))  # Encode string to bytes with UTF-8


        chat_history.append({"role": "assistant", "content": full_reply_content})
        c.close()
finally:
    s.close()
