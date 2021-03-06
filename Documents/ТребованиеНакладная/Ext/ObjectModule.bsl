﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Если СкладОтправитель = СкладПолучатель Тогда
		Сообщить("Проведение документа невозможно, склад отправитель не может совпадать со складом получателя.");
		Отказ = Истина;
		Возврат;
	КонецЕсли;	
	
	Движения.ОстаткиМатериалов.Записывать = Истина;
	Движения.ОстаткиМатериалов.Записывать = Истина;
	
	Для Каждого ТекСтрокаНоменклатура Из Номенклатура Цикл
		
		// регистр ОстаткиМатериалов Расход
		Движение = Движения.ОстаткиМатериалов.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Номенклатура = ТекСтрокаНоменклатура.Наименование;
		Движение.Склад = СкладОтправитель;
		Движение.Количество = ТекСтрокаНоменклатура.Количество;
		
		// регистр ОстаткиМатериалов Приход
		Движение = Движения.ОстаткиМатериалов.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Номенклатура = ТекСтрокаНоменклатура.Наименование;
		Движение.Склад = СкладПолучатель;
		Движение.Количество = ТекСтрокаНоменклатура.Количество;
	КонецЦикла;
	
	Движения.Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОстаткиМатериаловОстатки.Номенклатура КАК Номенклатура,
	|	ОстаткиМатериаловОстатки.Склад КАК Склад,
	|	-ОстаткиМатериаловОстатки.КоличествоОстаток КАК КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.ОстаткиМатериалов.Остатки КАК ОстаткиМатериаловОстатки
	|ГДЕ
	|	ОстаткиМатериаловОстатки.Склад = &Склад
	|	И ОстаткиМатериаловОстатки.КоличествоОстаток < 0";
	
	Запрос.УстановитьПараметр("Склад", СкладОтправитель);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	// ДАЕМ ЗВЕЗДЮЛЕЙ Юзеру за то, что двигает несуществующие материалы
	Если НЕ РезультатЗапроса.Пустой() Тогда
		
		Отказ = Истина;
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Сообщить("Передача невозможна, не хватает позиций по номенклатуре " + ВыборкаДетальныеЗаписи.Номенклатура + " на складе " + ВыборкаДетальныеЗаписи.Склад + " в количестве " + ВыборкаДетальныеЗаписи.КоличествоОстаток);
		КонецЦикла;
		
		
		
	КонецЕсли;
	
КонецПроцедуры
