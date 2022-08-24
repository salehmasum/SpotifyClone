//
//  AllCategoriesResponse.swift
//  SpotifyClone
//
//  Created by Saleh Masum on 11/8/2022.
//

import Foundation

struct AllCategoriesResponse: Codable {
    let categories: Category
}

struct Category: Codable {
    let items: [CategoryItem]
}

struct CategoryItem: Codable {
    let id: String
    let name: String
    let icons: [APIImage]
}

//{
//    categories =     {
//        href = "https://api.spotify.com/v1/browse/categories?country=AU&offset=0&limit=2";
//        items =         (
//                        {
//
//                icons =                 (
//                                        {
//                        height = 275;
//                        url = "https://t.scdn.co/media/derived/toplists_11160599e6a04ac5d6f2757f5511778f_0_0_275_275.jpg";
//                        width = 275;
//                    }
//                );
//
//                name = "Top Lists";
//            },
//                        {
//                href = "https://api.spotify.com/v1/browse/categories/pop";
//                icons =                 (
//                                        {
//                        height = 274;
//                        url = "https://t.scdn.co/media/derived/pop-274x274_447148649685019f5e2a03a39e78ba52_0_0_274_274.jpg";
//                        width = 274;
//                    }
//                );
//                id = pop;
//                name = Pop;
//            }
//        );
//    };
//}
