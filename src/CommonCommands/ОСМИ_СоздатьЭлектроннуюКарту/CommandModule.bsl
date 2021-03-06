
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	КартаОСМИ = ОСМИ_ОбщиеСервер.ПолучитьЭлектроннуюКарту(ПараметрКоманды);
	
	Если НЕ ЗначениеЗаполнено(КартаОСМИ) Тогда
		
		КартаОСМИ = СоздатьЭлектроннуюКартуНаСервере(ПараметрКоманды);
		Если ЗначениеЗаполнено(КартаОСМИ) Тогда
			
			СписокКнопок = Новый СписокЗначений;
			
			Телефон = ОСМИ_ОбщиеСервер.ПолучитьТелефонДляКарты1С(ПараметрКоманды);
			Если ЗначениеЗаполнено(Телефон) Тогда
				СписокКнопок.Добавить(1, "Телефон (СМС)");
			КонецЕсли;
			
			АдресПочты = ОСМИ_ОбщиеСервер.ПолучитьEmailДляКарты1С(ПараметрКоманды);
			Если ЗначениеЗаполнено(АдресПочты) Тогда
				СписокКнопок.Добавить(2, "Электронная почта");
			КонецЕсли;
			
			Если СписокКнопок.Количество() = 0 Тогда
				ПоказатьПредупреждение(, "Электронная карта создана!", 30, "Информация");
				Возврат;
			Иначе
				
				СписокКнопок.Добавить(0, "Нет");
			
				ПоказатьВопрос(Новый ОписаниеОповещения("СозданиеЭлектроннойКартыЗавершение", ЭтотОбъект,
					Новый Структура("Карта1С, КартаОСМИ", ПараметрКоманды, КартаОСМИ)),
						"Электронная карта создана!" + Символы.ПС +
						"Отправить электронную карту " +
							?(ЗначениеЗаполнено(Телефон), "на телефон (СМС)", "") + 
							?(ЗначениеЗаполнено(Телефон) И ЗначениеЗаполнено(АдресПочты), " или ", "") +
							?(ЗначениеЗаполнено(АдресПочты), "по электронной почте", "") + "?",
						СписокКнопок, 15,	0, "Внимание", 0);
				
			КонецЕсли;
				
		Иначе
			ПоказатьПредупреждение(, "Не удалось создать электронную карту на сервисе ОСМИ", 60, "Ошибка");
			Возврат;
		КонецЕсли;
		
	Иначе
		ПоказатьПредупреждение(, "Для данной карты 1С уже зарегистрирована электронная карта ОСМИ", 30, "Предупреждение");
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СозданиеЭлектроннойКартыЗавершение(ЗначениеОтвета, СтруктураКарт) Экспорт
	
	Если ЗначениеОтвета = 1 Тогда
		
		Телефон = ОСМИ_ОбщиеСервер.ПолучитьТелефонДляКарты1С(СтруктураКарт.Карта1С);
		Если НЕ ЗначениеЗаполнено(Телефон) Тогда
			ПоказатьПредупреждение(, "Не удалось получить номер телефона для отправки СМС", 30, "Ошибка");
			Возврат;
		КонецЕсли;
		
		Результат = ОСМИ_РаботаСAPI.ОтправитьПоСМС(ОСМИ_ОбщиеСервер.ПолучитьСерийныйНомерКартыОСМИ(СтруктураКарт.КартаОСМИ),
			Телефон);
		Если Результат.Успех Тогда
			ПоказатьПредупреждение(, "Запрос на отправку карты по СМС отправлен", 30, "Информация");
		Иначе
			ПоказатьПредупреждение(, "Ошибка выполнения к сервису ОСМИ для отправки СМС", 30, "Ошибка");
		КонецЕсли;
		
	ИначеЕсли ЗначениеОтвета = 2 Тогда
		
		АдресПочты = ОСМИ_ОбщиеСервер.ПолучитьEmailДляКарты1С(СтруктураКарт.Карта1С);
		Если НЕ ЗначениеЗаполнено(АдресПочты) Тогда
			ПоказатьПредупреждение(, "Не удалось получить адрес электронной почты для отправки СМС", 30, "Ошибка");
			Возврат;
		КонецЕсли;
		
		Результат = ОСМИ_РаботаСAPI.ОтправитьПоПочте(ОСМИ_ОбщиеСервер.ПолучитьСерийныйНомерКартыОСМИ(СтруктураКарт.КартаОСМИ),
			АдресПочты);
		Если Результат.Успех Тогда
			ПоказатьПредупреждение(, "Запрос на отправку карты по электронной почте отправлен", 30, "Информация");
		Иначе
			ПоказатьПредупреждение(, "Ошибка выполнения к сервису ОСМИ для отправки карты по электронной почте", 30, "Ошибка");
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СоздатьЭлектроннуюКартуНаСервере(Карта1С)
	
	КартаОСМИ = Справочники.ОСМИ_ЭлектронныеКарты.СоздатьКартуИзКарты1С(Карта1С);
	Возврат ?(КартаОСМИ = Неопределено ИЛИ КартаОСМИ.Ссылка.Пустая(), Неопределено, КартаОСМИ.Ссылка);

КонецФункции
