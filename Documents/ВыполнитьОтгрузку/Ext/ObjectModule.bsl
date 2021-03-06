﻿// переменные для записи себестоимости
Перем РеализованныйПродкут;
Перем КоличествоПродукции;

Процедура ОбработкаПроведения(Отказ, Режим)
	
	// регистр ОстаткиМатериалов Приход
	Движения.ОстаткиМатериалов.Записывать = Истина;
	Для Каждого ТекСтрокаСписокГотовойНоменклатуры Из СписокГотовойНоменклатуры Цикл
		Движение = Движения.ОстаткиМатериалов.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Номенклатура = ТекСтрокаСписокГотовойНоменклатуры.Номенклатура;
		Движение.Склад = Справочники.Склады.Основной;
		Движение.Количество = ТекСтрокаСписокГотовойНоменклатуры.Количество;
		
		РеализованныйПродкут = ТекСтрокаСписокГотовойНоменклатуры.Номенклатура;
		КоличествоПродукции = ТекСтрокаСписокГотовойНоменклатуры.Количество;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СебестоимостьНоменклатурыОстатки.Номенклатура КАК Номенклатура,
	|	СебестоимостьНоменклатурыОстатки.СуммаОстаток КАК СуммаОстаток,
	|	СебестоимостьНоменклатурыОстатки.КоличествоОстаток КАК КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.СебестоимостьНоменклатуры.Остатки(
	|			&МоментВремени,
	|			Номенклатура В
	|				(ВЫБРАТЬ
	|					ВыполнитьОтгрузкуСписокОтгружаемойНоменклатуры.Номенклатура КАК Номенклатура
	|				ИЗ
	|					Документ.ВыполнитьОтгрузку.СписокОтгружаемойНоменклатуры КАК ВыполнитьОтгрузкуСписокОтгружаемойНоменклатуры
	|				ГДЕ
	|					ВыполнитьОтгрузкуСписокОтгружаемойНоменклатуры.Ссылка = &Ссылка)) КАК СебестоимостьНоменклатурыОстатки";
	
	Запрос.УстановитьПараметр("МоментВремени", МоментВремени());
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	МассивОстатков = Запрос.Выполнить().Выгрузить();
	
	ОбщаяСебестоимостьИзготовления = 0;
	
	// регистр ОстаткиМатериалов Расход
	Движения.ОстаткиМатериалов.Записывать = Истина;
	Для Каждого ТекСтрокаСписокОтгружаемойНоменклатуры Из СписокОтгружаемойНоменклатуры Цикл
		Движение = Движения.ОстаткиМатериалов.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Номенклатура = ТекСтрокаСписокОтгружаемойНоменклатуры.Номенклатура;
		Движение.Склад = Справочники.Склады.Основной;
		Движение.Количество = ТекСтрокаСписокОтгружаемойНоменклатуры.Количество;
		
		// расчет себестоимости производства одной единицы продукции.
		Для Каждого СтрокаТЧ ИЗ МассивОстатков Цикл
			Если СтрокаТЧ.Номенклатура = ТекСтрокаСписокОтгружаемойНоменклатуры.Номенклатура Тогда 
				СебестоимостьИзготовленияЕдиницыПродукта = СтрокаТЧ.СуммаОстаток/СтрокаТЧ.КоличествоОстаток;
			КонецЕсли;
		КонецЦикла;
		
		СебестоимостьИзготовленияПоОдномуМатериалу = СебестоимостьИзготовленияЕдиницыПродукта * ТекСтрокаСписокОтгружаемойНоменклатуры.Количество;
		ОбщаяСебестоимостьИзготовления = ОбщаяСебестоимостьИзготовления + СебестоимостьИзготовленияПоОдномуМатериалу;		
	КонецЦикла;
	
	// регистр СебестоимостьНоменклатуры Приход
	Движения.СебестоимостьНоменклатуры.Записывать = Истина;
	
	Движение = Движения.СебестоимостьНоменклатуры.Добавить();
	Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
	Движение.Период = Дата;
	Движение.Номенклатура = РеализованныйПродкут;
	Движение.Количество = КоличествоПродукции;
	Движение.Сумма = ОбщаяСебестоимостьИзготовления;
	
	Движения.Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОстаткиМатериаловОстатки.Номенклатура КАК Номенклатура,
	|	ОстаткиМатериаловОстатки.Склад КАК Склад,
	|	-ОстаткиМатериаловОстатки.КоличествоОстаток КАК КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.ОстаткиМатериалов.Остатки(, ) КАК ОстаткиМатериаловОстатки
	|ГДЕ
	|	ОстаткиМатериаловОстатки.Склад = &Склад
	|	И ОстаткиМатериаловОстатки.КоличествоОстаток < 0";
	
	Запрос.УстановитьПараметр("Склад", Справочники.Склады.Основной);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		Отказ = Истина;
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Сообщить("Передача невозможна, не хватает позиций по номенклатуре " + ВыборкаДетальныеЗаписи.Номенклатура + " на складе " + ВыборкаДетальныеЗаписи.Склад + " в количестве " + ВыборкаДетальныеЗаписи.КоличествоОстаток);
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры
