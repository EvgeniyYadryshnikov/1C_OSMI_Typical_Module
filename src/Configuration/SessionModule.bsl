Процедура УстановкаПараметровСеанса(ТребуемыеПараметры)
	
	// Внимание! Указанный модуль приведен в качестве примера!
	// Не следует использовать его для типовых конфигураций на основе БСП!
	// 
	// В случае использования типовых конфигураций на основе БСП необходимо пользователься типовыми
	// механизмами инициализации параметров сеанса.
	//
	// Наилучшим вариантом будет вызов инициализации параметров сеанса через вызов функции
	// из модуля "ОбщегоНазначенияПереопределяемый.ПриДобавленииОбработчиковУстановкиПараметровСеанса()"
	// Образец добавляемого в функцию кода (в конце функции):
	//
	//		ОСМИ_УстановкаПараметровСеанса.ПриДобавленииОбработчиковУстановкиПараметровСеанса(Обработчики);
	//
	// ОСМИ - Начало
	Если ЗначениеЗаполнено(ТребуемыеПараметры) Тогда
		Если ТребуемыеПараметры.Найти("ОСМИ_КэшПараметровHTTPSАвторизации_cnonce") <> Неопределено Тогда
			ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_cnonce = "";
		КонецЕсли;
		Если ТребуемыеПараметры.Найти("ОСМИ_КэшПараметровHTTPSАвторизации_nc") <> Неопределено Тогда
			ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_nc = 1;
		КонецЕсли;
		Если ТребуемыеПараметры.Найти("ОСМИ_КэшПараметровHTTPSАвторизации_authorization") <> Неопределено Тогда
			ПараметрыСеанса.ОСМИ_КэшПараметровHTTPSАвторизации_authorization = "";
		КонецЕсли;
		Если ТребуемыеПараметры.Найти("ОСМИ_КлючИнформационнойСистемы") <> Неопределено Тогда
			ПараметрыСеанса.ОСМИ_КлючИнформационнойСистемы = Константы.ОСМИ_КлючИнформационнойСистемы.Получить();
		КонецЕсли;
		Если ТребуемыеПараметры.Найти("ОСМИ_ТекущийКлючИнформационнойСистемы") <> Неопределено Тогда
			ПараметрыСеанса.ОСМИ_ТекущийКлючИнформационнойСистемы = ОСМИ_ОбщиеСервер.СформироватьКлючИнформационнойСистемы();
		КонецЕсли;
	КонецЕсли;
	// ОСМИ - Окончание
	
КонецПроцедуры
