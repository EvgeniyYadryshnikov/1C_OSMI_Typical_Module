#Область  ВнутренниеФункции

#Область ПодготовкаСпециализированныхЗаголовковЗапросаДляДайджестАвторизации

Функция ПодготовитьСтруктуруДанныхПараметровАвторизации(ЗаголовкиОтветаСервера)
	
	СтруктураПараметровАвторизации = Неопределено;
	
	Для Каждого Элемент Из ЗаголовкиОтветаСервера Цикл
		Если ВРег(Элемент.Ключ) = "WWW-AUTHENTICATE" Тогда
			ОбрезанныйТекстАвторизации = СтрЗаменить(Элемент.Значение, "Digest ", "");

			СтруктураПараметровАвторизации = Новый Структура;
			
			ПозицияРазделителя = Найти(ОбрезанныйТекстАвторизации, ",");
			
			Пока ПозицияРазделителя > 0 Цикл
				ТекущаяСтрокаПараметра = Лев(ОбрезанныйТекстАвторизации, ПозицияРазделителя - 1);
				ОбрезанныйТекстАвторизации = Сред(ОбрезанныйТекстАвторизации, ПозицияРазделителя + 1); //чтобы не учитывался сам разделитель делаем +1
				ПозицияРазделителя = Найти(ОбрезанныйТекстАвторизации, ",");
				ПозицияРавно = Найти(ТекущаяСтрокаПараметра,"=");
				Если ПозицияРавно > 0 Тогда
					СтруктураПараметровАвторизации.Вставить(СокрЛП(Лев(ТекущаяСтрокаПараметра, ПозицияРавно - 1)),
						СтрЗаменить(СокрЛП(Сред(ТекущаяСтрокаПараметра, ПозицияРавно + 1)), """", ""));
				Иначе
					СтруктураПараметровАвторизации.Вставить(СокрЛП(ТекущаяСтрокаПараметра),"");
				КонецЕсли;	
			КонецЦикла;
			
			ТекущаяСтрокаПараметра = ОбрезанныйТекстАвторизации;
			ПозицияРавно = Найти(ТекущаяСтрокаПараметра,"=");
			Если ПозицияРавно > 0 Тогда
				СтруктураПараметровАвторизации.Вставить(СокрЛП(Лев(ТекущаяСтрокаПараметра,ПозицияРавно - 1)), 
					СтрЗаменить(СокрЛП(Сред(ТекущаяСтрокаПараметра, ПозицияРавно + 1)), """", ""));
			Иначе
				СтруктураПараметровАвторизации.Вставить(СокрЛП(ТекущаяСтрокаПараметра),"");
			КонецЕсли;	
			
			Прервать;
			
		КонецЕсли;
	КонецЦикла;
	
	Возврат СтруктураПараметровАвторизации;

КонецФункции

Функция ПолучитьСлучайноеКлиентскоеЧислоДляHTTPSАвторизации()
	
	Если НЕ ЗначениеЗаполнено(ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_cnonce) Тогда
		ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_cnonce = 
			НРег(Лев(СтрЗаменить(Строка(РасчетХешаМД5(Строка(ИмяКомпьютера() + ТекущаяДата()))), " ", ""), 8));
	КонецЕсли;
	
	Возврат ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_cnonce;
		
КонецФункции

Функция ПолучитьПорядковыйНомерЗапросаДляHTTPSАвторизации()
	
	ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_nc = ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_nc + 1;
	Возврат Лев("00000000" + ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_nc, 8);
	
КонецФункции

#КонецОбласти

Функция ОпределитьПараметрыПодключения(ПараметрыПодключения)
	
	Если ПараметрыПодключения = Неопределено Тогда
		
		ПараметрыПодключения = Новый Структура("APIID, APIKEY, APIADDR, ИспользоватьСертификат",
			Константы.ОСМИ_APIID.Получить(), Константы.ОСМИ_APIKEY.Получить(), Константы.ОСМИ_APIADDR.Получить(),
			Константы.ОСМИ_ИспользоватьСертификат.Получить());
			
		Если ПараметрыПодключения.ИспользоватьСертификат Тогда
				
			ПараметрыПодключения.Вставить("ПутьКСертификату", Константы.ОСМИ_РасположениеСертификата.Получить());
			ПараметрыПодключения.Вставить("ПарольСертификата", Константы.ОСМИ_ПарольОтСертификата.Получить());
			
		КонецЕсли;	
			
	КонецЕсли;
	
	Возврат ПараметрыПодключения;
	
КонецФункции

Функция РасчетХешаМД5(Текст)
	
	ОбъектХеш = Новый ХешированиеДанных(ХешФункция.MD5); 
	ОбъектХеш.Добавить(Текст); 
	Возврат ОбъектХеш.ХешСумма;
	
КонецФункции

Функция ОтправитьЗапрос(Метод, Ресурс, Параметры = "", ПараметрыПОСТ = Неопределено,
	ПараметрыПодключения = Неопределено, ОтключитьПроверкуКлючаИнформационнойСистемы = Ложь) 

	СтруктураОтвета = Новый Структура("Ответ, ТекстОтвета, Успех, ОписаниеОшибки, Статус");
	
	Если НЕ ОтключитьПроверкуКлючаИнформационнойСистемы И
		НЕ ОСМИ_ОбщиеСервер.ПроверитьКлючИнформационнойСистемы() Тогда
		СтруктураОтвета.Успех = Ложь;
		СтруктураОтвета.ОписаниеОшибки = "Некорректный ключ информационной системы!";
		ОСМИ_ОбщиеСервер.ЗарегистрироватьОшибкуОСМИ(СтруктураОтвета.ОписаниеОшибки,, Ложь);
		Возврат СтруктураОтвета;
	КонецЕсли;
	
	СтруктураЗапроса = Новый Структура("Метод, Ресурс, Параметры, ПараметрыПОСТ", Метод, Ресурс, Параметры, ПараметрыПОСТ);
	
	СтрокаJS = Сериализовать(СтруктураЗапроса);
	
	ПараметрыПодключения = ОпределитьПараметрыПодключения(ПараметрыПодключения); 
	
	ЗаписьЖурналаРегистрации("ОСМИ.Отправка запроса", УровеньЖурналаРегистрации.Информация,,, СтрокаJS); 
			
	Попытка
		
		АдресРесурсаСПараметрами = ?(ПараметрыПодключения.ИспользоватьСертификат, "/v2c/", "/v2/") + Ресурс +
			?(Параметры = "", "", "?" + Параметры);
		Запроc = Новый HTTPЗапрос(АдресРесурсаСПараметрами);
			
		Если НЕ ПараметрыПост = Неопределено Тогда
			Запроc.УстановитьТелоИзСтроки(СокрЛП(ПараметрыПОСТ));
		КонецЕсли;
		
		Если ПараметрыПодключения.ИспользоватьСертификат Тогда
			
			Соединение = Новый HTTPСоединение(ПараметрыПодключения.APIADDR, 443,,,,,
				Новый ЗащищенноеСоединениеOpenSSL(Новый СертификатКлиентаФайл(ПараметрыПодключения.ПутьКСертификату,
				ПараметрыПодключения.ПарольСертификата)));
			Ответ = Соединение.ВызватьHTTPМетод(Метод, Запроc); 
			
		Иначе
			
			Соединение = Новый HTTPСоединение(ПараметрыПодключения.APIADDR, 443, ПараметрыПодключения.APIID, ПараметрыПодключения.APIKEY,, 30,
				Новый ЗащищенноеСоединениеOpenSSL(Неопределено, Неопределено));
			
			Запроc.Заголовки.Вставить("Authorization", ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_authorization); 
				
			Ответ = Соединение.ВызватьHTTPМетод(Метод, Запроc);
			
			Если Ответ.КодСостояния = 401 Тогда //Предполагаем, что дайджест просрочен - получаем новый
			
				СтруктураПараметровАвторизации = ПодготовитьСтруктуруДанныхПараметровАвторизации(Ответ.Заголовки);
				Если НЕ ЗначениеЗаполнено(СтруктураПараметровАвторизации) Тогда
					ВызватьИсключение "Ошибка авторизации на сервисе";
				КонецЕсли;
			
				cnonce = ПолучитьСлучайноеКлиентскоеЧислоДляHTTPSАвторизации();
				nc = ПолучитьПорядковыйНомерЗапросаДляHTTPSАвторизации();
				
				ХешИтог = НРег(СтрЗаменить(РасчетХешаМД5(НРег(СтрЗаменить(РасчетХешаМД5(ПараметрыПодключения.APIID +
					":" + СтруктураПараметровАвторизации.realm + ":" + ПараметрыПодключения.APIKEY)," ","")) + ":" +
					СтруктураПараметровАвторизации.nonce + ":" + nc + ":" + cnonce + ":" + СтруктураПараметровАвторизации.qop + ":" +
					НРег(СтрЗаменить(РасчетХешаМД5(Метод + ":" + АдресРесурсаСПараметрами)," ","")))," ",""));
					
				ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_authorization = "Digest username=" + ПараметрыПодключения.APIID + ",realm=" + 
					СтруктураПараметровАвторизации.realm + ",nonce=" + СтруктураПараметровАвторизации.nonce  + ",uri=" + АдресРесурсаСПараметрами  + ",qop=" + 
					СтруктураПараметровАвторизации.qop  + ",nc=" + nc + ",cnonce=" + cnonce + ",response=" + ХешИтог + ",opaque=" + 
					СтруктураПараметровАвторизации.opaque;
				
				Запроc.Заголовки.Вставить("Authorization", ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_authorization);
				
				Ответ = Соединение.ВызватьHTTPМетод(Метод, Запроc);
					
			КонецЕсли;			

		КонецЕсли;
				
		СтруктураОтвета.Статус = Ответ.КодСостояния;		
		СтруктураОтвета.ТекстОтвета = Ответ.ПолучитьТелоКакСтроку();
			
		Если СтруктураОтвета.Статус = 200 Тогда 			
			
			Чтение = Новый ЧтениеJSON;
			Чтение.УстановитьСтроку(СтруктураОтвета.ТекстОтвета);
			СтруктураОтвета.Ответ =
				ПрочитатьJSON(Чтение,,,, "ФункцияВосстановления", ОСМИ_ПовторноИспользуемый.МодульФункцииВосстановления());
			Чтение.Закрыть();
			
			СтруктураОтвета.Успех = Истина;
			
			ЗаписьЖурналаРегистрации("ОСМИ.ОСМИ.Ответ на запрос", УровеньЖурналаРегистрации.Информация,,, Сериализовать(СтруктураОтвета));
			
		ИначеЕсли  СтруктураОтвета.Статус = 204 Тогда
						
			СтруктураОтвета.Успех = Истина;
			
			ЗаписьЖурналаРегистрации("ОСМИ.Ответ на запрос", УровеньЖурналаРегистрации.Информация,,, Сериализовать(СтруктураОтвета));

		Иначе
			
			СтруктураОтвета.ТекстОтвета =  СтруктураОтвета.ТекстОтвета;
			СтруктураОтвета.Успех = Ложь;			
			
			ОСМИ_ОбщиеСервер.ЗарегистрироватьОшибкуОСМИ("Ответ на запрос: " + Символы.ПС + Сериализовать(СтруктураОтвета),, Ложь);
			
		КонецЕсли; 
		
	Исключение
		
		СтруктураОтвета.Успех = Ложь;
		СтруктураОтвета.ОписаниеОшибки = ОписаниеОшибки();

		ОСМИ_ОбщиеСервер.ЗарегистрироватьОшибкуОСМИ("Ответ на запрос: " + Символы.ПС + СтруктураОтвета.ОписаниеОшибки,, Ложь);
		
	КонецПопытки;
	
	СтруктураОтвета.Вставить("Запрос", СтруктураЗапроса);
	
	Возврат СтруктураОтвета;
	
КонецФункции

Функция ПустуюСтрокуВAPI(Строка) 
	
	Если Строка = "" тогда
		Возврат "-empty-"
	Иначе
		Возврат Строка;
	КонецЕсли;
	
КонецФункции

Функция Сериализовать(СтруктураДанных)

	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку();
	ЗаписатьJSON(ЗаписьJSON, СтруктураДанных);
	Возврат ЗаписьJSON.Закрыть();
	
КонецФункции

#КонецОбласти

#Область  ЭкспортныеФункции
// Функция - Проверить подключение к сервису
// 
// Возвращаемое значение:
//  Структура - Возвращает структуру результата подключения к сервису, содержащую успешность выполнения и версию сервиса на сервере. 
//
Функция ПроверитьПодключениеКСервису(ПараметрыПодключения = Неопределено) Экспорт
	
	Возврат ОтправитьЗапрос("GET", "ping",,, ПараметрыПодключения, Истина);
	
КонецФункции

// Функция - Запросить информацию по карте
//
// Параметры:
//  СерийныйНомер			 - Строка - Серийный номер карты;
//  ДополнительнаяИнформация - Булево - Нужна ли в структуре возврата дополнительная информация
// 
// Возвращаемое значение:
//   - Структура
//
Функция ЗапроситьИнформациюПокарте(СерийныйНомер, ДополнительнаяИнформация = Ложь)  Экспорт 
	
	Возврат ОтправитьЗапрос("GET", "passes/" + 
		КодироватьСтроку(СокрЛП(СерийныйНомер), СпособКодированияСтроки.КодировкаURL),
		?(ДополнительнаяИнформация, "extendedInfo=true", ""),,, Истина);	
		
КонецФункции

// Функция - Запросить список доступных шаблонов
//
// Параметры:
//  Статистика	 - Булево - нужна ли статистика по шаблонам
// 
// Возвращаемое значение:
//   - Структура 
//
Функция ЗапроситьСписокДоступныхШаблонов(Статистика = Ложь) Экспорт
	
	Возврат ОтправитьЗапрос("GET", "templates", ?(Статистика, "stats=true", ""),,, Истина);

КонецФункции

// Функция - Запросить информацию о шаблоне
//
// Параметры:
//  ИмяШаблона	 - Строка - Имя шаблона на сервере
// 
// Возвращаемое значение:
//   - Структура
//
Функция ЗапроситьИнформациюОШаблоне(ИмяШаблона) Экспорт
	
	Возврат ОтправитьЗапрос("GET", "templates/" + 
		КодироватьСтроку(СокрЛП(ИмяШаблона), СпособКодированияСтроки.КодировкаURL),,,, Истина);			
		
КонецФункции

// Функция - Создать карту
//
// Параметры:
//  СерийныйНомер		 - Строка - Серийный номер создаваемой карты
//  ИмяШаблона			 - Строка - Имя шаблона, по которому создается карта
//  ЗаполнитьЗначения	 - Булево - Нужно ли заполнять карту данными при создании
//  СтруктураКарты		 - Структура - нужно указывать только если ЗаполнитьЗначения = истина. Структура параметров карты, указываемых при создании
// 
// Возвращаемое значение:
//   - Структура 
//
Функция СоздатьКарту(СерийныйНомер, ИмяШаблона, ЗаполнитьЗначения = Ложь, СтруктураКарты = Неопределено) Экспорт
	
	Возврат ОтправитьЗапрос("POST","passes/"
		+ КодироватьСтроку(СокрЛП(СерийныйНомер),СпособКодированияСтроки.КодировкаURL) + "/" 
		+ КодироватьСтроку(СокрЛП(ИмяШаблона), СпособКодированияСтроки.КодировкаURL), 
		?(ЗаполнитьЗначения, "withValues=true", ""), Сериализовать(СтруктураКарты),, Ложь);
	
КонецФункции

// Функция - Обновить значения карты
//
// Параметры:
//  СерийныйНомер	 - Строка - Серийный номер обновляемой карты	
//  СтруктураКарты	 - Структура - Данные, передаваемые на карту
//  ОтправлятьПуш	 - Булево - Нужно ли при обновлении отправлять пуш сообщение
// 
// Возвращаемое значение:
//   - Структура
//
Функция ОбновитьЗначенияКарты(СерийныйНомер, СтруктураКарты, ОтправлятьПуш = Истина) Экспорт	
	
	Возврат ОтправитьЗапрос("PUT", "passes/" +
		КодироватьСтроку(СокрЛП(СерийныйНомер), СпособКодированияСтроки.КодировкаURL) +
		?(ОтправлятьПуш, "/push", ""),, Сериализовать(СтруктураКарты),, Ложь);

КонецФункции 

// Функция - Отправить пуш сообщение
//
// Параметры:
//  всеКарты		 - Булево - отправлять сообщение на все карты 
//  СерийныеНомера	 - Массив - Массив номер карт получателей сообения 
//  шаблоны			 - Массив - Массив имен шаблонов, на карты которых отправлять сообщение  
//  датаНачала		 - Дата - Дата, после которой будет отправлено сообщение 
//  сообщение		 - Строка - Текст сообщения
// 
// Возвращаемое значение:
//   - Структура
//
Функция ОтправитьПушСообщение(всеКарты = Ложь, СерийныеНомера = Неопределено, Шаблоны = Неопределено,
	ДатаНачала = Неопределено, Сообщение) Экспорт
	              
	СтруктураПараметров = Новый Структура("message", Сообщение);
	
	Если всеКарты Тогда 
		СтруктураПараметров.Вставить("allCards", всеКарты);
	ИначеЕсли НЕ Шаблоны = Неопределено Тогда
		МассивШБ = Новый Массив;
		Для Каждого ШБ Из Шаблоны Цикл
			МассивШБ.Добавить(ШБ);
		КонецЦикла;
		СтруктураПараметров.Вставить("templates", МассивШБ);
	ИначеЕсли не СерийныеНомера = Неопределено Тогда
		МассивСН = Новый Массив;
		Для Каждого Сн Из СерийныеНомера Цикл
			МассивСН.Добавить(СокрЛП(Сн));
		КонецЦикла;
		СтруктураПараметров.Вставить("serials", МассивСН);
	КонецЕсли;
	Если ЗначениеЗаполнено(ДатаНачала) Тогда
		СтруктураПараметров.Вставить("start",
			Формат(УниверсальноеВремя(ДатаНачала, ЧасовойПояс()), "ДФ=гггг-ММ-ддTЧЧ:мм:ссZ"));
	КонецЕсли;                                              	
	
	Структура = ОтправитьЗапрос("POST", "marketing/pushmessage",, Сериализовать(СтруктураПараметров),, Ложь);

КонецФункции

// Функция - Отправить динамическую акцию
//
// Параметры:
//  всеКарты		 - Булево - Отправлять акцию на все карты 
//  СерийныеНомера	 - Массив - Список карт на которые отправлять акцию
//  шаблоны			 - Массив - Список шаблонов, на карты которых отправлять акцию
//  датаНачала		 - Дата - Дата начала отображения акции
//  ДатаЗавершения	 - Дата - Дата завершения отображения акции
//  Заголовок		 - Строка - Заголовок поля акции
//  ТекстПоля		 - Строка - Текст поля акции
//  сообщение		 - Строка - Текст пуш сообщения 
//  Картинка		 - Строка - Фоновая картинка карты, устанавливаемая на время действия акции
//  ЦветЗаголовков	 - Строка - Цвет текста заголовка акции в формате html
//  ЦветТекста		 - Строка - Цвет текста акции в формате html
//  ЦветФона		 - Строка - Цвет фона карты, устанавливаемая на время действия акции
// 
// Возвращаемое значение:
//   - Структура
//
Функция ОтправитьДинамическуюАкцию(всеКарты = Ложь, СерийныеНомера = Неопределено, Шаблоны = Неопределено, 
	ДатаНачала = Неопределено, ДатаЗавершения = Неопределено, Заголовок = Неопределено, ТекстПоля="-empty-",
	Сообщение = Неопределено, Картинка = "-empty-", ЦветЗаголовков = "-empty-", ЦветТекста = "-empty-",
	ЦветФона = "-empty-") Экспорт
		
	СтруктураПараметров = Новый Структура("body, image", ТекстПоля, Картинка);
	
	Если ЗначениеЗаполнено(ДатаНачала) Тогда	
		СтруктураПараметров.Вставить("start",
			Формат(УниверсальноеВремя(ДатаНачала, ЧасовойПояс()), "ДФ=гггг-ММ-ддTЧЧ:мм:ссZ"));
	КонецЕсли;
	Если ЗначениеЗаполнено(ДатаЗавершения) Тогда	
		СтруктураПараметров.Вставить("end",
			Формат(УниверсальноеВремя(ДатаЗавершения, ЧасовойПояс()), "ДФ=гггг-ММ-ддTЧЧ:мм:ссZ"));
	КонецЕсли;
	Если ЗначениеЗаполнено(Заголовок) Тогда
		СтруктураПараметров.Вставить("label", Заголовок);
	КонецЕсли;

	СтруктураПараметров.Вставить("colors", Новый Структура("label, foreground, background",
		ПустуюСтрокуВAPI(ЦветЗаголовков), ПустуюСтрокуВAPI(ЦветТекста), ПустуюСтрокуВAPI(ЦветФона)));
	
	Если ЗначениеЗаполнено(Сообщение) Тогда
		СтруктураПараметров.Вставить("message", Сообщение);		
	КонецЕсли;	
		
	Если всеКарты Тогда 
		СтруктураПараметров.Вставить("allCards", всеКарты);
	ИначеЕсли не Шаблоны = Неопределено Тогда
		МассивШБ = Новый Массив;
		Для Каждого ШБ из Шаблоны Цикл
			МассивШБ.Добавить(ШБ);
		КонецЦикла;
		СтруктураПараметров.Вставить("templates", МассивШБ);
	ИначеЕсли НЕ СерийныеНомера = Неопределено Тогда
		СтруктураПараметров.Вставить("serials", СерийныеНомера);
	КонецЕсли;
	
	Возврат ОтправитьЗапрос("POST", "marketing/pushaction",, Сериализовать(СтруктураПараметров),, Ложь);

КонецФункции

// Функция - Обновить значения шаблона
//
// Параметры:
//  ИмяШаблона		 - Строка - Имя обновляемого шаблона
//  СтруктураДанных	 - Структура - Структура обновляемого шаблона
//  ОтправитьПуш	 - Булево - Отправлять ли на карты шаблона пуш сообщение с изменениями в шаблоне
// 
// Возвращаемое значение:
//   - Структура 
//
Функция ОбновитьЗначенияШаблона(ИмяШаблона, СтруктураДанных, ОтправитьПуш = Ложь) Экспорт
	
	Возврат ОтправитьЗапрос("PUT", "templates/" +
		КодироватьСтроку(СокрЛП(ИмяШаблона), СпособКодированияСтроки.КодировкаURL) + 
		?(ОтправитьПуш, "/push", ""),, Сериализовать(СтруктураДанных),, Ложь);
		
КонецФункции

// Функция - Сменить шаблон
//
// Параметры:
//  СерийныйНомер	 - Строка - Серийный номер карты который хотите перевести на другой шаблон
//  Шаблон			 - Строка - Имя шаблона на который хотите перевести карту
// 
// Возвращаемое значение:
//   - Структура
//
Функция СменитьШаблон(СерийныйНомер, Шаблон) Экспорт
	
	Возврат ОтправитьЗапрос("PUT", "passes/move/" +
		КодироватьСтроку(СокрЛП(СерийныйНомер), СпособКодированияСтроки.КодировкаURL) + "/" +
		КодироватьСтроку(Шаблон, СпособКодированияСтроки.КодировкаURL) + "/push",,,, Ложь);	
		
КонецФункции

// Функция - Получить список доступных графических файлов
// 
// Возвращаемое значение:
//   - Структура
//
Функция ПолучитьСписокДоступныхГрафическихФайлов() Экспорт
	
	Возврат ОтправитьЗапрос("GET", "images",,,, Ложь);

КонецФункции

// Функция - Запросить информацию о графическом файле из библиотеки
//
// Параметры:
//  IDКартинки	 - Строка - Идентификатор картинки
// 
// Возвращаемое значение:
//   - Струкутра
//
Функция ЗапроситьИнформациюОГрафическомФайлеИзБиблиотеки(IDКартинки) Экспорт
	
	Возврат ОтправитьЗапрос("GET", "images/" +
		КодироватьСтроку(СокрЛП(IDКартинки), СпособКодированияСтроки.КодировкаURL) + "/data",,,, Ложь);
		
КонецФункции

// Функция - Добавить новый графический файл
//
// Параметры:
//  Тип	 - Перечисления.ОСМИ_ТипыКартинок - Тип картинки. 
//  Имя	 - Строка - Имя картинки
//  ДД	 - ДвоичныеДанные - Данные картинки 
// 
// Возвращаемое значение:
//   - Струкутра
//
Функция ДобавитьНовыйГрафическийФайл(ТипКартинки, ИмяКартинки, ДанныеКартинки) Экспорт
	
	Возврат ОтправитьЗапрос("POST",	"images",, Сериализовать(Новый Структура("imgType, imgDescription, imgData",
		Метаданные.Перечисления[ТипКартинки.Метаданные().Имя].ТипКартинки[Перечисления[ТипКартинки.Метаданные().Имя].Индекс(ТипКартинки)].Имя,
		ИмяКартинки, ДанныеКартинки)),, Ложь);
	
КонецФункции

// Функция - Отправить по СМС
//
// Параметры:
//  СерийныйНомер	 - Строка - Серийный номер карты отправляемый по СМС 
//  Телефон			 - Строка - Номер телефона
// 
// Возвращаемое значение:
//   - Струкутра
//
Функция ОтправитьПоСМС(СерийныйНомер, Телефон, ТекстОповещения = "") Экспорт		
	
	Возврат ОтправитьЗапрос("GET", "passes/" +
		КодироватьСтроку(СокрЛП(СерийныйНомер), СпособКодированияСтроки.КодировкаURL) + "/sms/" +
		КодироватьСтроку(СтрЗаменить(Телефон, " ", ""), СпособКодированияСтроки.КодировкаURL),
		?(ТекстОповещения <> "", "message=" + КодироватьСтроку(ТекстОповещения, СпособКодированияСтроки.КодировкаURL), ""),,,
		Истина);	
		
КонецФункции

// Функция - Отправить по почте
//
// Параметры:
//  СерийныйНомер	 - Строка - Серийный номер карты отправляемый по электронной почте. 
//  Почта			 - Строка - Адрес электронной почты, на который отправляется карты
// 
// Возвращаемое значение:
//   - Струкутра
//
Функция ОтправитьПоПочте(СерийныйНомер, Почта, ТекстСообщения = "") Экспорт
	
	Возврат ОтправитьЗапрос("POST", "passes/" +
		КодироватьСтроку(СокрЛП(СерийныйНомер), СпособКодированияСтроки.КодировкаURL) + "/email/" +
		КодироватьСтроку(СтрЗаменить(Почта, " ", ""), СпособКодированияСтроки.КодировкаURL),,
		?(ТекстСообщения <> "",
			Сериализовать(Новый Структура("body", КодироватьСтроку(ТекстСообщения, СпособКодированияСтроки.КодировкаURL))),
			Неопределено),, Истина);
		
КонецФункции

// Функция - Получить список групп
// 
// Возвращаемое значение:
//   - Струкутра
//
Функция ПолучитьСписокГрупп() Экспорт
	
	Возврат ОтправитьЗапрос("GET","registration/groups",,,, Истина);	
	
КонецФункции

// Функция - Удалить регистрацию
//
// Параметры:
//  МассивКарт	 - Массив - Массив серийных номеров 
// 
// Возвращаемое значение:
//   - Струкутра 
//
Функция УдалитьРегиcтрацию(МассивКарт) Экспорт

	Если МассивКарт.Количество() = 0 Тогда
		Возврат Новый Структура("Успех", Истина);
	Иначе
		Возврат ОтправитьЗапрос("POST","registration/deletedata",,
			Сериализовать(Новый Структура("registrations", МассивКарт)),, Ложь);
	КонецЕсли;
	
КонецФункции

// Функция - Получить список зарегистрированных карт
//
// Параметры:
//  Группа	 - Строка - мя регистрационной группы
// 
// Возвращаемое значение:
//   - Структура
//
Функция ПолучитьСписокЗарегистрированныхКарт(Группа, ВключаяПомеченныеНаУдаление = Ложь) Экспорт
	
	Возврат ОтправитьЗапрос("GET", "registration/data/" +
		КодироватьСтроку(СокрЛП(Группа), СпособКодированияСтроки.КодировкаURL),
		?(ВключаяПомеченныеНаУдаление, "withDeleted=true", ""),,, Истина); 		
		
КонецФункции

// Функция - Получить статус доставки пуш сообщения (возвращает последнюю дату получения телефоном карты)
//
// Параметры:
//  Дата		 - Дата - Дата, после которой проверяется статус доставки
//  НомерКарты	 - Строка - Номер проверяемой карты
// 
// Возвращаемое значение:
//   - Структура
//
Функция ПолучитьСтатусДоставкиПушСообщения(Дата = Неопределено, НомерКарты = Неопределено) Экспорт
	
	Параметры = "";
	Если ЗначениеЗаполнено(Дата) Тогда	
		Параметры = "start=" + Формат(УниверсальноеВремя(Дата, ЧасовойПояс()), "ДФ=гггг-ММ-ддTЧЧ:мм:ссZ");
	КонецЕсли;
	Если ЗначениеЗаполнено(НомерКарты) Тогда	
		Параметры = Параметры + "serialNo=" + КодироватьСтроку(СокрЛП(НомерКарты), СпособКодированияСтроки.КодировкаURL);
	КонецЕсли;
	
	Возврат ОтправитьЗапрос("GET", "stats/delivery", Параметры,,, Истина);
		
КонецФункции

// Функция - Получить список настроенных событиый
// 
// Возвращаемое значение:
//   - Структура
//
функция ПолучитьСписокНастроенныхСобытиый() Экспорт
	
	Возврат ОтправитьЗапрос("GET", "events",,,, Истина);
	
КонецФункции

// Функция - Установить новое событие
//
// Параметры:
//  Метод			 - Строка - HTTP Метод 
//  Адрес			 - Строка - Адрес веб/http сервиса
//  ИмяПользователя	 - Строка - Имя пользователя для авторизации на сервисе
//  Пароль			 - Строка - Пароль пользователя для авторизации на сервисе 
//  Порт			 - Строка - Порт веб сервера
//  Событие			 - Строка - Идентификатор события
// 
// Возвращаемое значение:
//   - Структура
//
Функция УстановитьОбработчикСобытия(Метод, Адрес, ИмяПользователя = "", Пароль = "", Порт = "", Событие) Экспорт

	Возврат ОтправитьЗапрос("POST", "events/" + Событие,,
		Сериализовать(Новый Структура("method, url, user, password, port", Метод, Адрес, ИмяПользователя, Пароль, Порт)),,
		Ложь);
		
КонецФункции

Функция УдалитьОбработчикСобытия(Событие) Экспорт

	Возврат ОтправитьЗапрос("POST", "events/" + Событие,, Сериализовать(
		Новый Структура("url", "-empty-")),, Ложь);
		
КонецФункции

Функция ПолучитьРеферальныеДанные(СерийныйНомер) Экспорт
	
	Возврат ОтправитьЗапрос("GET", "referrer/" +
		КодироватьСтроку(СокрЛП(СерийныйНомер), СпособКодированияСтроки.КодировкаURL),,,, Истина);
	
КонецФункции

Функция ОтправитьПИН(Телефон) Экспорт
	
	Возврат ОтправитьЗапрос("POST", "activation/sendpin/" +
		СтрЗаменить(СтрЗаменить(СтрЗаменить(СокрЛП(Телефон), "-", ""), "+", ""), " ", ""),,,, Истина);
	
КонецФункции
	
Функция ПроверитьПИН(Токен, ПИН) Экспорт
	
	Возврат ОтправитьЗапрос("POST", "activation/checkpin",,
		Сериализовать(Новый Структура("token, pin", СокрЛП(Токен), СокрЛП(ПИН))),, Истина);	
	
КонецФункции

Функция УдалитьЭлектроннуюКарту(СерийныйНомер, ПолноеУдаление = Ложь, ОтправитьPUSH = Ложь) Экспорт		
	
	Возврат ОтправитьЗапрос("DELETE", "passes/" + КодироватьСтроку(СокрЛП(СерийныйНомер), СпособКодированияСтроки.КодировкаURL) +
		?(ОтправитьPUSH, "/push", ""), "purge=" + ?(ПолноеУдаление, "true", "false"),,, Ложь);	
		
КонецФункции

#КонецОбласти

