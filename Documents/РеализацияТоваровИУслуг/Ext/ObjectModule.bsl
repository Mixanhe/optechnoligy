﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	Движения.ОстаткиМатериалов.Записывать = Истина;
	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.ОстаткиМатериалов.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.Склад = Склад;
		Движение.Количество = ТекСтрокаТовары.Количество;
	КонецЦикла;
	
	
	#Область КонтроляОстатков
	Движения.Записать();
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОстаткиМатериаловОстатки.Номенклатура КАК Номенклатура,
	|	ОстаткиМатериаловОстатки.Склад КАК Склад,
	|	-ОстаткиМатериаловОстатки.КоличествоОстаток КАК Количество
	|ИЗ
	|	РегистрНакопления.ОстаткиМатериалов.Остатки(
	|			,
	|			Номенклатура В
	|				(ВЫБРАТЬ
	|					РеализацияТоваровИУслугТовары.Номенклатура КАК Номенклатура
	|				ИЗ
	|					Документ.РеализацияТоваровИУслуг.Товары КАК РеализацияТоваровИУслугТовары
	|				ГДЕ
	|					РеализацияТоваровИУслугТовары.Ссылка = &Ссылка)) КАК ОстаткиМатериаловОстатки
	|ГДЕ
	|	ОстаткиМатериаловОстатки.КоличествоОстаток < 0";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		
		Отказ = Истина;
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			
			Сообщить("Не хватает позиций товара " + ВыборкаДетальныеЗаписи.Номенклатура + " в количестве " + ВыборкаДетальныеЗаписи.Количество + " на складе "  + ВыборкаДетальныеЗаписи.Склад);
			
		КонецЦикла;
		
	КонецЕсли;
	
	
	
	
	
	#КонецОбласти
	
#Область РасчетСебестоимость

Если Отказ Тогда
	Возврат;
КонецЕсли



  




#КонецОбласти
	
КонецПроцедуры
