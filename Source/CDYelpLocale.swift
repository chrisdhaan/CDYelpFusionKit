//
//  CDYelpLocale.swift
//  CDYelpFusionKit
//
//  Created by Christopher de Haan on 7/25/17.
//
//  Copyright © 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

///
/// A list of locales the Yelp Fusion API supports. The locale code is in the format of {language code}_{country code}.
///
public enum CDYelpLocale: String, Sendable {
    // swiftlint:disable identifier_name
    case chinese_hongKong = "zh_HK"
    case chinese_taiwan = "zh_TW"
    case czech_czechRepublic = "cs_CZ"
    case danish_denmark = "da_DK"
    case dutch_belgium = "nl_BE"
    case dutch_theNetherlands = "nl_NL"
    case english_australia = "en_AU"
    case english_belgium = "en_BE"
    case english_canada = "en_CA"
    case english_hongKong = "en_HK"
    case english_malaysia = "en_MY"
    case english_newZealand = "en_NZ"
    case english_philippines = "en_PH"
    case english_republicOfIreland = "en_IE"
    case english_singapore = "en_SG"
    case english_switzerland = "en_CH"
    case english_unitedKingdom = "en_GB"
    case english_unitedStates = "en_US"
    case filipino_philippines = "fil_PH"
    case finnish_finland = "fi_FI"
    case french_belgium = "fr_BE"
    case french_canada = "fr_CA"
    case french_france = "fr_FR"
    case french_switzerland = "fr_CH"
    case german_austria = "de_AT"
    case german_germany = "de_DE"
    case german_switzerland = "de_CH"
    case italian_italy = "it_IT"
    case italian_switzerland = "it_CH"
    case japanese_japan = "ja_JP"
    case malay_malaysia = "ms_MY"
    case norwegian_norway = "nb_NO"
    case polish_poland = "pl_PL"
    case portuguese_brazil = "pt_BR"
    case portuguese_portugal = "pt_PT"
    case spanish_argentina = "es_AR"
    case spanish_chile = "es_CL"
    case spanish_mexico = "es_MX"
    case spanish_spain = "es_ES"
    case swedish_finland = "sv_FI"
    case swedish_sweden = "sv_SE"
    case turkish_turkey = "tr_TR"
    // swiftlint:enable identifier_name
}
