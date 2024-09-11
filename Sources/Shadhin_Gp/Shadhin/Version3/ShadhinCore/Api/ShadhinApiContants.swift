//
//  ShadhinApiContants.swift
//  Shadhin
//
//  Created by Gakk Alpha on 8/26/21.
//  Copyright © 2021 Cloud 7 Limited. All rights reserved.
//

import Foundation

public class ShadhinApiContants {
    var API_HEADER: HTTPHeaders {
        get{
            var header = [
                "Token" : !(ShadhinCore.instance.defaults.userSessionToken.isEmpty) ? ShadhinCore.instance.defaults.userSessionToken : "aU9T",
                "Content-Type" : "application/json"
            ]
            if !ShadhinCore.instance.defaults.userSessionToken.isEmpty{
                header["Authorization"] = "Bearer \(ShadhinCore.instance.defaults.userSessionToken)"
            }
            header["countryCode"] = ShadhinCore.instance.defaults.geoLocation.lowercased()
            header["DeviceType"] =  "iOS"
            return  HTTPHeaders.init(header)
        }
    }
    let CONTENT_HEADER: HTTPHeaders = HTTPHeaders.init(["Content-Type" : "application/json"])
    var runningCampaignInRamCache : [String]? = nil
    let cbc_secret_key = "andgraphicdesign"
    let cbc_iv = "shing1248andgrap"
    var isRestrictionPaidAlertNotShowing = true
    let locationUpdateDelayInSecs: Double =  5 //15 * (24 * 60 * 60)
    //let RBTSubscriptionIDs = [["30AYCEOT", "30AYCELT"], ["7AYCEOT","7AYCELT"], ["1AYCEOT", "1AYCELT"]]
    let X_Compatibility = "2"
    let customArtistBio = [
        "habib%20wahid" : "Habib wahid is a Bangladeshi music composer, performer, producer &amp; singer. He has been successful working in the Bangladeshi music industry since 2003 when his first album “kirshno” got released, which was mainly made with a vision of re introducing old Bengali folk songs re made with a new sound completely to popularise them to the audience. Ever since then, he has worked on many original albums, flim songs, jingles for tv commercials etc. He has won several awards including a national award for uja contribution in the music industry. Habib wahid also has a major contribution in modernising the concept of Bangladeshi music videos through his video “Hariye fela bhalobasha” released in 2015. Since then he has been working regularly on producing and performing in his music videos. Apart from singing his own original songs, habib has features various artists over the years of which some gained tremendous success like Nancy, who has been known as a regular duet singing partner of habib. Habib wahid has performed in live concerts throughout many counties of the world like USA, Canada, uk, Australia, Dubai, Qatar, malaysia, and many more. Habib wahid is always appreciated by his fans for his unique, authentic and original approach towards composing music.",
        "shafin%20ahmed" : "Shafin Ahmed as a composer, lyricist, singer and Bassist, is an icon today in the music industry. Exceptional musical talent inherited from his legendary parents, Kamal Dasgupta and Feroza Begum, combined with his own dedication applied over 40 years have established him permanently in the hearts and minds of millions of Bangla music listeners around the world.",
        "miles" : "Miles was formed in 1979 in Dhaka, Bangladesh with eyes looking ahead on miles of travel through time in Music. After 40 years with many changes in the line up, Tours and achievements behind, the band is still pursuing the excellence in music. Considered one of the leading Rock Fusion bands of the Sub-Continent and perhaps the only band in Asia to exist at the top for so long with it’s core members, it has a very unique blend of Eastern &amp; Western music in their generic  Bangla Songs to create a very diversified trend in the Bengali music scene in Bangladesh, India, USA, Canada and rest of the world. Rich in melody, blended with power with very matured arrangements and application of instruments, Miles have their own distinct sound that has captured the heart and soul of the Bengali music fans all over the world for four decades now. In Bangladesh, Miles have so far released 2 English,  7 Bengali albums, and an EP, that are -  Miles, A Step Further, Protisruty, Prattasha, Prattay, Prabaha, Pratiddhani, Protichobi, Proticchobi Delux, and Prayash and in India 3 albums: Best of volume 1 &amp; Volume 2. and Proborton. Each of these albums are considered milestones for “Bangla Rock” music in Bangladesh as well as in India in terms of both sales &amp; unique blend of Miles’ music.   USA, Canada, U.K., Italy, Germany, Austria, Switzerland, Australia. UAE,  and India are some of the countries that MILES have rocked along with numerous concerts in Bangladesh till date. It is the only Band in Bangladesh to have been covered by MTV, Channel “V”, CNN, BBC, Al-Jazeera, Star Plus, ETV India, B4U, Zee-TV and Tara Bangla. MILES has also made number of international appearances for charitable causes as well.   Miles’ current line up is- Hamin Ahmed-  Vocal &amp; Guitar, Shafin Ahmed- Vocal &amp; Bass, Manam Ahmed- Keyboards &amp; Vocal,  Ziaur Rahman Turja- Drums &amp; Percussions and Iqbal Asif Jewel- Guitar and Vocal.   Miles is determined to rock on with “Bangla Rock Fusion” for the international recognition and that determination is still driving the Band to miles of music ahead,!!",
        "popeye" : "Popeye is a Bangladeshi music project that has been active for a decade. They do not perform in concerts, nor appear on television, and cannot be heard on the radio. Yet they have quietly garnered a cult following among rock-fusion lovers in Bangladesh over the last few years.",
        "the%20roads" : "THE ROADS is a Rock band formed in Dhaka, Bangladesh. They started their musical journey from 2011. THE ROADS performed numerous shows LIVE shows, TV shows, Radio shows, Online shows etc. Their released songs are MonePore, Bristy, ChenaGaan, Sritir-Michil, Dakghor, Jadu Khela, MonDuary, Dheu and more. THE ROADS is grateful for the Love and Support from their fans to keep them encouraged and going forward. THE ROADS is - Aapel Mahmud (Voice & Lead Guitars), Zaki Mahmud (Rhythm Guitar & Manager), Blaze Rodrigues (Bass), Shirajul Islam Munna (Drums), Aapel Mahmud Labu (Keyboards). You can reach them at their fan-page: www.facebook.com/theroadsbandbd",
        "micky" : "Mehedi Hasan (born 1 April 2002), better known by his stage name Mïcky is a Singer, Songwriter, Music Producer, Composer and Dancer from Dhaka, Bangladesh. He is renowned for his unique ideas, not sticking to any specific genre and representing different vibes to everyone through his music. Also, he likes to combine and play with different genres. His first music was officially released on February 14, 2021, titled as 'Fragrance’. He started producing music when he was 16, but he is still underrated in his country. Mïcky wants to spread the message through his music that music is so beautiful that it can spread positivity and inspire people in their daily life and can help to reach their major goals. That's why he wants his listeners to be a part of his journey!",
        "ayan" : "AYAN, a growing musician based in Dhaka, Bangladesh who has been making music from different genres, a versatile musician who has his unique touch in different songs he has worked in.",
        "eyecon" : "EYECON, formerly known as A$H is an Artist originating from Sunamganj, Sylhet, Bangladesh. He started making music from the year 2016 and never looked back. He redefined his music style through the years and now he became more versatile excelling in a lot of genres. He belongs to the collective CLVR where they collectively work to bring new sounds and expression of art to display to the world. Genres: Pop Punk, Alternative Rock, Emo Rock, Hip-hop, R&B.",
        "feedback" : "Feedback is a Bangladeshi rock band, formed in 4 October 1976 in Dhaka by keyboardist Foad Nasser Babu. Multiple lineup changes have taken place since 1976. They have released seven studio albums and have also appeared in some compilations. Their first appearance was in The Hotel Inter-continental (now the Sheraton), Dhaka, on 11 October 1976. Their first recorded song was 'Aye Din Chiro Din Robey' in 1980. After Labu Rahman joined the band in 1986, they started concerts out of the hotels. They released their first album Feedback and then Sragam Acoustics. Feedback performed at Shilpakala Academy on 25 September 1989, at Dhaka University on 16 December 1990, at Nicco Park, Kolkata on 26 January 1992, at Jadavpur University on 12 July 1994."
        
    ]
    
    static func getCallerTuneServices()->[CallerTuneObj]{
        let gpCallerTuneServiceJson = "[{\"amount\":\"৳32.83\",\"duration\":\"30 days\",\"serviceID\":[\"30AYCEOT\",\"30AYCELT\"]},{\"amount\":\"৳7.66\",\"duration\":\"7 days\",\"serviceID\":[\"7AYCEOT\",\"7AYCELT\"]},{\"amount\":\"৳1.09\",\"duration\":\"1 day\",\"serviceID\":[\"1AYCEOT\",\"1AYCELT\"]}]"
        let blCallerTuneServiceJson = "[{\"amount\":\"৳30.00\",\"duration\":\"30 days\",\"serviceID\":[\"OT30\",\"NAYCE\"]}]"
        
        switch ShadhinCore.instance.getUserTelcoBrand(){
        case .GrameenPhone:
            return try! JSONDecoder().decode(
                [CallerTuneObj].self,
                from: Data(gpCallerTuneServiceJson.utf8))
        case .BanglaLink:
            return try! JSONDecoder().decode(
                [CallerTuneObj].self,
                from: Data(blCallerTuneServiceJson.utf8))
        default:
            return []
        }
    }
    
    func getAPIHeaderForUserInfo(token: String) -> HTTPHeaders {
        var header = [
            "Token" : token,
            "Content-Type" : "application/json"
        ]
        
        header["Authorization"] = "Bearer \(token)"
        
        header["countryCode"] = ShadhinCore.instance.defaults.geoLocation.lowercased()
        header["DeviceType"] =  "iOS"
        return  HTTPHeaders.init(header)
    }
    
    
    var API_HEADER_FOR_NEWSUBSCRIPTION: HTTPHeaders {
        get{
            var header = [
                "Token" : !(ShadhinCore.instance.defaults.userSessionToken.isEmpty) ? ShadhinCore.instance.defaults.userSessionToken : "aU9T",
                "Content-Type" : "application/json"
            ]
            if !ShadhinCore.instance.defaults.userSessionToken.isEmpty{
                header["Authorization"] = "Bearer hG8mCmeIaD9mHDpui/fSvYYBPMxCXEdGuZhh//BHiqoJHOowMaov8Bya++hwg8XNQc/FTrwlEwr7c7R63f2GOTucyfuim/Y+/0r+vphrjkjxyx6ZCWzHNvRwt79Yo7eb1G98L0d+mRDNo6aaArq7stxYGAZpHCmh7zP1TmtO7HxAKilnANm7oL9WYbzffEsqiJ2+ixOgv6LMl3jDkAHwhlr2DCxYpsFIOrdS45O4wjT24/IcB1BCIxNembkuf8FKEc/Nn6hcwJM2JdSN9kMoaTZSq17VVV0GiBwypGgwJFJX4fLxXL5BOFwsyj8rbmEHYiy/vZeReLdoYG3knX+hf5sFjNvV8/8VtKBmIrCiH1Z22oaACvTvmh/vJ04+Cv3eemji/6GnQhjJONx4wRQMejPWG0uY7eTJutm+z/4H+NjQP9eBXJvcdgKYKjlldPg7vkFCCl3rSUxMIcayc/3+eBAuYthvK7/CbLTekmQCzknjBynIN6WyHmtsL5QUFSiQlrv3bgYBMtRJrtheZdhpghlkVBFuQ0ViOmYVPe5ZK2n5fGKDDx4t9JlqAzaqicBWsQ1hDNhTvXe1PirNksESZ0pAN4ODT5kQj9sidc2RcMMJps+ARYY0ICOXWjdJA1ISZkSrIO/JubY2X0/fY332KjU/GshFWSKtn0iNtHn5xvEM+kDjHStgQFLJqXVwAad+5nTjzD3I+4/BuzVFNExfv2In5gr3Itr8Lqd9PhkDr3s0BQR8pG3GGGF0KHFy6sEvuazpUxsFLBLB+CtRw6jXYiwYo5qwSLwNh07k4owY25i5WRZKx5X1FjqAPxIJX2h7I7A05UgfzNKTSQ3tR/eIY7qCJFJUFPWutS0L29n8jPFUmGz69GPwoWcGhCCGfkxJpxBjZp7XrMVwEw3JCdLeeWL1MAsOGQhKkbncSw2p8ORvFf4uGnlp7z+fhHQxf5ZHsmcY6m2xDNkoRfGGY6uSbXqsH3/4MeiSz/AUcNLNf3Su/9oTN7TkWhAV4ojScVGT5qKf/6l01LlH+cvrDWDKsmPpynVDAvKFDcqM2g906by9OTO1jaiEc+qm7Z5m4HGNmuNVN/FQhNsjcn//FNuCywAQ/A6707NsRZ+CGkyv6es=:W4f9+02ncJ+go+zvASCX+A=="
            }
            header["countryCode"] = ShadhinCore.instance.defaults.geoLocation.lowercased()
            header["DeviceType"] =  "iOS"
            return  HTTPHeaders.init(header)
        }
    }
}


