# Service for exporting invoices and cancellations to datev/csv format
# Documentation see misc/documentation/datev-export

class BusinessdocumentExportDatevCsv
  require 'csv'

  def get_invoicepositions(account, businessdocumentpositions, date_from, date_to)
    @businessdocumentpositions = businessdocumentpositions
    @account = account

    # Col 6: Date file is created Format: JJJJMMTTHHMMSS (+3 Stellen für Tausendstelsekunden)
    created_at = DateTime.now.strftime('%Y%m%d%H%M%S000').to_s

    # Col 11: Tax consultant ID, Beraternummer, Wert zwischen 1001 und 9999999
    tax_consultant_id = (@account.tax_consultant_id.present? ? @account.tax_consultant_id.to_s : "9999999")

    # Col 12: Tax consultant client ID, Mandantennummer, Wert zwischen 1 und 99999
    tax_consultant_client_id = (@account.tax_consultant_client_id.present? ? @account.tax_consultant_client_id.to_s : "9999999")

    # Col 13: Fiscal year start, Wirtschaftsjahresbeginn Format: JJJJMMTT
    fiscal_year_start = "#{DateTime.now.strftime('%Y').to_s + sprintf('%02.0f', @account.fiscal_year_start_day).to_s + sprintf('%02.0f', @account.fiscal_year_start_month).to_s}"



    header_row_1 = ["\"EXTF\"", "500", "21", "\"Buchungsstapel\"", "9", "#{created_at}", "", "\"\"", "\"\"", "", "#{tax_consultant_id}", "#{tax_consultant_client_id}", "#{fiscal_year_start}", "4", "#{date_from.to_date.strftime('%Y%m%d').to_s}", "#{date_to.to_date.strftime('%Y%m%d').to_s}", "\"Rechnungen\"", "\"NN\"", "", "", "0", "\"EUR\"", "", "\"\"", "", "", "\"\"", "", "", "", "\"Wundercoach\""]

    header_row_2 = ["Umsatz (ohne Soll/Haben-Kz)", "Soll/Haben-Kennzeichen", "WKZ Umsatz", "Kurs", "Basis-Umsatz", "WKZ Basis-Umsatz", "Konto", "Gegenkonto (ohne BU-Schlüssel)", "BU-Schlüssel", "Belegdatum", "Belegfeld 1", "Belegfeld 2", "Skonto", "Buchungstext", "Postensperre", "Diverse Adressnummer", "Geschäftspartnerbank", "Sachverhalt", "Zinssperre", "Beleglink", "Beleginfo - Art 1", "Beleginfo - Inhalt 1", "Beleginfo - Art 2", "Beleginfo - Inhalt 2", "Beleginfo - Art 3", "Beleginfo - Inhalt 3", "Beleginfo - Art 4", "Beleginfo - Inhalt 4", "Beleginfo - Art 5", "Beleginfo - Inhalt 5", "Beleginfo - Art 6", "Beleginfo - Inhalt 6", "Beleginfo - Art 7", "Beleginfo - Inhalt 7", "Beleginfo - Art 8", "Beleginfo - Inhalt 8", "KOST1 - Kostenstelle", "KOST2 - Kostenstelle", "Kost-Menge", "EU-Land u. UStID", "EU-Steuersatz", "Abw. Versteuerungsart", "Sachverhalt L+L", "Funktionsergänzung L+L", "BU 49 Hauptfunktionstyp", "BU 49 Hauptfunktionsnummer", "BU 49 Funktionsergänzung", "Zusatzinformation - Art 1", "Zusatzinformation- Inhalt 1", "Zusatzinformation - Art 2", "Zusatzinformation- Inhalt 2", "Zusatzinformation - Art 3", "Zusatzinformation- Inhalt 3", "Zusatzinformation - Art 4", "Zusatzinformation- Inhalt 4", "Zusatzinformation - Art 5", "Zusatzinformation- Inhalt 5", "Zusatzinformation - Art 6", "Zusatzinformation- Inhalt 6", "Zusatzinformation - Art 7", "Zusatzinformation- Inhalt 7", "Zusatzinformation - Art 8", "Zusatzinformation- Inhalt 8", "Zusatzinformation - Art 9", "Zusatzinformation- Inhalt 9", "Zusatzinformation - Art 10", "Zusatzinformation- Inhalt 10", "Zusatzinformation - Art 11", "Zusatzinformation- Inhalt 11", "Zusatzinformation - Art 12", "Zusatzinformation- Inhalt 12", "Zusatzinformation - Art 13", "Zusatzinformation- Inhalt 13", "Zusatzinformation - Art 14", "Zusatzinformation- Inhalt 14", "Zusatzinformation - Art 15", "Zusatzinformation- Inhalt 15", "Zusatzinformation - Art 16", "Zusatzinformation- Inhalt 16", "Zusatzinformation - Art 17", "Zusatzinformation- Inhalt 17", "Zusatzinformation - Art 18", "Zusatzinformation- Inhalt 18", "Zusatzinformation - Art 19", "Zusatzinformation- Inhalt 19", "Zusatzinformation - Art 20", "Zusatzinformation- Inhalt 20", "Stück", "Gewicht", "Zahlweise", "Forderungsart", "Veranlagungsjahr", "Zugeordnete Fälligkeit", "Skontotyp", "Auftragsnummer", "Buchungstyp", "Ust-Schlüssel (Anzahlungen)", "EU-Land (Anzahlungen)", "Sachverhalt L+L (Anzahlungen)", "EU-Steuersatz (Anzahlungen)", "Erlöskonto (Anzahlungen)", "Herkunft-Kz", "Buchungs GUID", "KOST-Datum", "Mandatsreferenz", "Skontosperre", "Gesellschaftername", "Beteiligtennummer", "Identifikationsnummer", "Zeichnernummer", "Postensperre bis", "BezeichnungSoBil-Sachverhalt", "KennzeichenSoBil-Buchung", "Festschreibung", "Leistungsdatum", "Datum"]

    CSV.generate(headers: false, col_sep: ";", force_quotes: false, encoding:'utf-8') do |csv_content|
      csv_content << header_row_1
      csv_content << header_row_2
      @businessdocumentpositions.each do |businessdocumentposition|
        # csv << attributes.map {|attr| eventbooking.send(attr) }
        csv_content << [
            "#{(businessdocumentposition.gross_sum < 0 ? businessdocumentposition.gross_sum * -1 : businessdocumentposition.gross_sum)}",
            "#{(businessdocumentposition.businessdocument.type == "Billing::Invoice" ? "S" : "H")}",
            "#{businessdocumentposition.businessdocument.currency.present? ? businessdocumentposition.businessdocument.currency : 'EUR'}",
            "",
            "",
            "",
            "#{@account.revenue_account}",
            "#{businessdocumentposition&.businessdocument&.contact&.account_receivable_no}",
            "",
            "#{(businessdocumentposition.businessdocument.invoice_date != '' ? businessdocumentposition.businessdocument.invoice_date.to_date.strftime('%d%m').to_s : '')}",
            "#{businessdocumentposition.businessdocument.invoice_number}",
            "#{(businessdocumentposition.businessdocument.due_date.present? ? businessdocumentposition.businessdocument.due_date.to_date.strftime('%d%m%y').to_s : '')}",
            "","","","","","","",
            "",
            "Beschreibung",
            "#{(!businessdocumentposition&.businessdocument&.contact ? businessdocumentposition&.businessdocument&.recipient_name1.to_s + ' ' + businessdocumentposition&.businessdocument&.recipient_name2.to_s: businessdocumentposition&.businessdocument&.contact.name.to_s + ' ' + businessdocumentposition&.businessdocument&.contact.name2.to_s + ' ' + businessdocumentposition&.businessdocument&.contact.firstname.to_s + ' ' + businessdocumentposition&.businessdocument&.contact.lastname.to_s)}",
            "Umsatzsteuerprozent",
            "#{(businessdocumentposition&.vat&.value ? businessdocumentposition&.vat&.value * 100 : '')}",
            "Name","","","",
            "Nettobetrag",
            "#{(businessdocumentposition.total_price_net < 0 ? businessdocumentposition.total_price_net * -1 : businessdocumentposition.total_price_net)}",
            "Steuerbetrag",
            "#{(businessdocumentposition.total_vat_amount < 0 ? businessdocumentposition.total_vat_amount * -1 : businessdocumentposition.total_vat_amount)}",
            "Leistungsdatum","2202",
            "Kundennummer","#{businessdocumentposition&.businessdocument&.contact&.account_receivable_no}",
            "","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","0","",""]
      end
    end
    # csv_content
  end

  # def get_invoices(businessdocumentpositions)
  #
  # end

  def get_contacts(account, businessdocumentpositions)

    @businessdocumentpositions = businessdocumentpositions
    @account = account

    header_row_1 = [
        "EXTF", #1. EXTF = für Dateiformate, die von externen Programmen erstellt wurden
        "700", #2. Versionsnummer des Headers.
        "16", #3. Datenkategorie: 16 = Debitoren-/Kreditoren
        "Debitoren/Kreditoren", #4. Formatname: Debitoren/Kreditoren
        "5", #5. Versionsnummer des Formats - Aktueller Stand der Formatversionen: Debitoren/Kreditoren = 5
        "", #6. Erzeugt am - Format: JJJJMMTTHHMMSS (+3 Stellen für Tausendstelsekunden). Bsp.: 20180329065650770
        "", #7. leer
        "EX", #8. Herkunft: Export, EX, frei wählbar.
        "", #9. Name des Benutzers
        "", #10. Importiert von, wird bei Import gesetzt
        "#{@account.tax_consultant_id}", #11. Beraternummer, Wert zwischen 1001 und 9999999
        "#{@account.tax_consultant_client_id}", #12. Mandantennummer, Wert zwischen 1 und 99999
        "#{@account.export_fixed_at_start_date}", #13. Wirtschaftsjahresbeginn Format: JJJJMMTT
        "4", #14. Kleinste Sachkontennummernlänge = 4, Debitoren/Kreditoren dann 5 Stellen, Größte Sachkontennummernlänge = 8 bzw. 9 bei Personenkonten
        "", #15. Datum "von“ des Buchungsstapels, Bsp: 20180301, kann bei Debitoren/Kreditoren leer sein
        "", #16. Datum "bis" des Buchungsstapels, Bsp: 20180301, kann bei Debitoren/Kreditoren leer sein
        "", #17. Bezeichnung des Buchungsstapels
        "","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]

    header_row_2 = ["Konto","Name (Adressattyp Unternehmen)","Unternehmensgegenstand","Name (Adressattyp natürl. Person)","Vorname (Adressattyp natürl. Person)","Name (Adressattyp keine Angabe)","Adressatentyp","Kurzbezeichnung","EU-Land","EU-UStID","Anrede","Titel/Akad. Grad","Adelstitel","Namensvorsatz","Adressart","Straße","Postfach","Postleitzahl","Ort","Land","Versandzusatz","Adresszusatz","Abweichende Anrede","Abw. Zustellbezeichnung 1","Abw. Zustellbezeichnung 2","Kennz. Korrespondenzadresse","Adresse Gültig von","Adresse Gültig bis","Telefon","Bemerkung (Telefon)","Telefon Geschäftsleitung","Bemerkung (Telefon GL)","E-Mail","Bemerkung (E-Mail)","Internet","Bemerkung (Internet)","Fax","Bemerkung (Fax)","Sonstige","Bemerkung (Sonstige)","Bankleitzahl 1","Bankbezeichnung 1","Bank-Kontonummer 1","Länderkennzeichen 1","IBAN-Nr. 1","Leerfeld 1","SWIFTCode 1","Abw. Kontoinhaber 1","Kennz. Hauptbankverb. 1","Bankverb. 1 Gültig von","Bankverb. 1 Gültig bis","Bankleitzahl 2","Bankbezeichnung 2","Bank-Kontonummer 2","Länderkennzeichen 2","IBAN-Nr. 2","Leerfeld 2","SWIFTCode 2","Abw. Kontoinhaber 2","Kennz. Hauptbankverb. 2","Bankverb. 2 Gültig von","Bankverb. 2 Gültig bis","Bankleitzahl 3","Bankbezeichnung 3","Bank-Kontonummer 3","Länderkennzeichen 3","IBAN-Nr. 3","Leerfeld 3","SWIFTCode 3","Abw. Kontoinhaber 3","Kennz. Hauptbankverb. 3","Bankverb. 3 Gültig von","Bankverb. 3 Gültig bis","Bankleitzahl 4","Bankbezeichnung 4","Bank-Kontonummer 4","Länderkennzeichen 4","IBAN-Nr. 4","Leerfeld 4","SWIFTCode 4","Abw. Kontoinhaber 4","Kennz. Hauptbankverb. 4","Bankverb. 4 Gültig von","Bankverb. 4 Gültig bis","Bankleitzahl 5","Bankbezeichnung 5","Bank-Kontonummer 5","Länderkennzeichen 5","IBAN-Nr. 5","Leerfeld 5","SWIFTCode 5","Abw. Kontoinhaber 5","Kennz. Hauptbankverb. 5","Bankverb. 5 Gültig von","Bankverb. 5 Gültig bis","Leerfeld A","Briefanrede","Grußformel","Kundennummer","Steuernummer","Sprache","Ansprechpartner","Vertreter","Sachbearbeiter","Diverse-Konto","Ausgabeziel","Währungssteuerung","Kreditlimit (Debitor)","Zahlungsbedingung","Fälligkeit in Tagen (Debitor)","Skonto in Prozent (Debitor)","Kreditoren-Ziel 1 (Tage)","Kreditoren-Skonto 1 (%)","Kreditoren-Ziel 2 (Tage)","Kreditoren-Skonto 2 (%)","Kreditoren-Ziel 3 Brutto (Tage)","Kreditoren-Ziel 4 (Tage)","Kreditoren-Skonto 4 (%)","Kreditoren-Ziel 5 (Tage)","Kreditoren-Skonto 5 (%)","Mahnung","Kontoauszug","Mahntext 1","Mahntext 2","Mahntext 3","Kontoauszugstext","Mahnlimit Betrag","Mahnlimit %","Zinsberechnung","Mahnzinssatz 1","Mahnzinssatz 2","Mahnzinssatz 3","Lastschrift","Verfahren","Mandantenbank","Zahlungsträger","Indiv. Feld 1","Indiv. Feld 2","Indiv. Feld 3","Indiv. Feld 4","Indiv. Feld 5","Indiv. Feld 6","Indiv. Feld 7","Indiv. Feld 8","Indiv. Feld 9","Indiv. Feld 10","Indiv. Feld 11","Indiv. Feld 12","Indiv. Feld 13","Indiv. Feld 14","Indiv. Feld 15","Abweichende Anrede Rechnungsadresse","Adressart Rechnungsadresse","Straße Rechnungsadresse","Postfach Rechnungsadresse","Postleitzahl Rechnungsadresse","Ort Rechnungsadresse","Land Rechnungsadresse","Versandzusatz Rechnungsadresse","Adresszusatz Rechnungsadresse","Abw. Zustellbezeichnung 1 Rechnungsadresse","Abw. Zustellbezeichnung 2 Rechnungsadresse","Adresse Gültig von Rechnungsadresse","Adresse Gültig bis Rechnungsadresse","Bankleitzahl 6","Bankbezeichnung 6","Bank-Kontonummer 6","Länderkennzeichen 6","IBAN-Nr. 6","Leerfeld 6","SWIFTCode 6","Abw. Kontoinhaber 6","Kennz. Hauptbankverb. 6","Bankverb. 6 Gültig von","Bankverb. 6 Gültig bis","Bankleitzahl 7","Bankbezeichnung 7","Bank-Kontonummer 7","Länderkennzeichen 7","IBAN-Nr. 7","Leerfeld 7","SWIFTCode 7","Abw. Kontoinhaber 7","Kennz. Hauptbankverb. 7","Bankverb. 7 Gültig von","Bankverb. 7 Gültig bis","Bankleitzahl 8","Bankbezeichnung 8","Bank-Kontonummer 8","Länderkennzeichen 8","IBAN-Nr. 8","Leerfeld 8","SWIFTCode 8","Abw. Kontoinhaber 8","Kennz. Hauptbankverb. 8","Bankverb. 8 Gültig von","Bankverb. 8 Gültig bis","Bankleitzahl 9","Bankbezeichnung 9","Bank-Kontonummer 9","Länderkennzeichen 9","IBAN-Nr. 9","Leerfeld 9","SWIFTCode 9","Abw. Kontoinhaber 9","Kennz. Hauptbankverb. 9","Bankverb. 9 Gültig von","Bankverb. 9 Gültig bis","Bankleitzahl 10","Bankbezeichnung 10","Bank-Kontonummer 10","Länderkennzeichen 10","IBAN-Nr. 10","Leerfeld 10","SWIFTCode 10","Abw. Kontoinhaber 10","Kennz. Hauptbankverb. 10","Bankverb. 10 Gültig von","Bankverb. 10 Gültig bis","Nummer Fremdsystem","Insolvent","SEPA-Mandatsreferenz 1","SEPA-Mandatsreferenz 2","SEPA-Mandatsreferenz 3","SEPA-Mandatsreferenz 4","SEPA-Mandatsreferenz 5","SEPA-Mandatsreferenz 6","SEPA-Mandatsreferenz 7","SEPA-Mandatsreferenz 8","SEPA-Mandatsreferenz 9","SEPA-Mandatsreferenz 10","Verknüpftes OPOS-Konto","Mahnsperre bis","Lastschriftsperre bis","Zahlungssperre bis","Gebührenberechnung","Mahngebühr 1","Mahngebühr 2","Mahngebühr 3","Pauschalenberechnung","Verzugspauschale 1","Verzugspauschale 2","Verzugspauschale 3"]

    CSV.generate(headers: false, col_sep: ";", force_quotes: true, encoding:'utf-8') do |csv_content|
      csv_content << header_row_1
      csv_content << header_row_2

      @contact_ids = []
      @businessdocumentpositions.each do |businessdocumentposition|
        @contact_ids << businessdocumentposition.get_contact.id.to_s unless businessdocumentposition.get_contact.nil?
      end
      # @contact_ids = @businessdocumentpositions.pluck(:contact_id)

      @contacts = Crm::Contact.includes(:contact_addresses).distinct.find(@contact_ids)
      @contacts.each do |contact|
        csv_content << [
                          "#{contact.account_receivable_no}",
                          "#{contact.name}",
                          "#{contact.name2}",
                          "#{contact.lastname}",
                          "#{contact.firstname}",
                          "#{contact.get_primary_address.street}",
                          "#{contact.get_primary_address.zip}",
                          "#{contact.get_primary_address.city}",
                          "#{contact.get_primary_address.country}"]
      end

    end

  end

end
