Функция МодульФункцииВосстановления() Экспорт
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	Версия = СтрРазделить(СистемнаяИнформация.ВерсияПриложения, "."); 
	
	Возврат ?(Число(Версия[2]) > 5, ОСМИ_Общие8313, ОСМИ_Общие836);  
	
КонецФункции
   