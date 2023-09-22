```
#!/usr/bin/env python3
from subprocess import check_output
import telebot
import time

bot = telebot.TeleBot("6635857058:AAEjm_mYKwwNjiG4nhJm8bnqRoL-hM49saw")#токен бота
@bot.message_handler(content_types=["text"])
def main(message):
    #проверяем, что пишет именно владелец
     comand = message.text  #текст сообщения
     print(comand)
     comand = comand.lstrip('/')
     try: #если команда невыполняемая - check_output выдаст exception
        bot.send_message(message.chat.id, check_output(comand, shell = True))
     except:
        bot.send_message(message.chat.id, "Invalid input") #если команда некорректна
if __name__ == '__main__':
    while True:
        try:#добавляем try для бесперебойной работы
            print('noerror')
            bot.polling(none_stop=True)#запуск бота
        except exception as e:
            print(e)
            print("eroor")
            time.sleep(10)#в случае падения
```
