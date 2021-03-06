﻿
&НаСервере
Функция СотрудникиСменыФИОПриИзмененииНаСервере(Сотрудник)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Сотрудники.Должность КАК Должность,
	|	Сотрудники.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Сотрудники КАК Сотрудники
	|ГДЕ
	|	Сотрудники.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Сотрудник);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	ВыборкаДетальныеЗаписи.Следующий();
	
	Возврат ВыборкаДетальныеЗаписи.Должность;
	
КонецФункции

&НаКлиенте
Процедура СотрудникиСменыФИОПриИзменении(Элемент)
	Сотрудник = Элементы.СотрудникиСмены.ТекущиеДанные;
	Сотрудник.Должность = СотрудникиСменыФИОПриИзмененииНаСервере(Сотрудник.ФИО);
	ПроверкаДвойнойЗаписиНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ПодборСотрудников(Команда)
	
	ПараметрыФормы = Новый Структура("МножественныйВыбор", Истина);
	ОткрытьФорму("Справочник.Сотрудники.ФормаВыбора",
	ПараметрыФормы, Элементы.СотрудникиСмены);
	
КонецПроцедуры

&НаКлиенте
Процедура СотрудникиСменыОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Для Каждого ВыбранныйЭлемент Из ВыбранноеЗначение Цикл
		НоваяСтрока = Объект.СотрудникиСмены.Добавить();
		НоваяСтрока.ФИО = ВыбранныйЭлемент;
	КонецЦикла;
	
	ЗаполнитьКолонкуДолжностейНаСервере();
	ПроверкаДвойнойЗаписиНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьКолонкуДолжностейНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Сотрудники.Должность КАК Должность,
	|	Сотрудники.Ссылка КАК Сотрудник
	|ИЗ
	|	Справочник.Сотрудники КАК Сотрудники
	|ГДЕ
	|	Сотрудники.ЭтоГруппа = ""ЗАВОД""";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Для Каждого СтрокаТЧ Из Объект.СотрудникиСмены Цикл
			
			Если ВыборкаДетальныеЗаписи.Сотрудник = СтрокаТЧ.ФИО Тогда
				СтрокаТЧ.Должность = ВыборкаДетальныеЗаписи.Должность;
			КонецЕсли;
			
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере                                                       
Процедура ПроверкаДвойнойЗаписиНаСервере()	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	УстановкаРабочейСменыСотрудникиСмены.ФИО КАК ФИО
	|ИЗ
	|	Документ.УстановкаРабочейСмены.СотрудникиСмены КАК УстановкаРабочейСменыСотрудникиСмены
	|ГДЕ
	|	УстановкаРабочейСменыСотрудникиСмены.Ссылка <> &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Для Каждого СтрокаТЧ Из Объект.СотрудникиСмены Цикл
			
			Если СтрокаТЧ.ФИО = ВыборкаДетальныеЗаписи.ФИО Тогда	
				Сообщить("Сотрудник " + ВыборкаДетальныеЗаписи.ФИО + " уже записан в другой смене "  );
			КонецЕсли;
			
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры