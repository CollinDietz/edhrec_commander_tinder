import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';

class CardWidget extends StatelessWidget {
  final String url;

  const CardWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Center(child: Icon(Icons.broken_image)),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EDHREC Commander Tinder',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'EDHREC Commander Tinder'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final Map<String, String> commander = {
    "name": "Gwen Stacy",
    "url":
        "https://cards.scryfall.io/normal/front/b/0/b0f1597f-1dc7-465e-8fcb-0afe61bcca46.jpg?1757432940",
  };

  final List<Map<String, String>> cardData = [
    {
      "name": "Mountain",
      "url":
          "https://cards.scryfall.io/normal/front/c/4/c44f81ca-f72f-445c-8901-3a894a2a47f9.jpg?1755290125",
    },
    {
      "name": "Island",
      "url":
          "https://cards.scryfall.io/normal/front/a/2/a2e22347-f0cb-4cfd-88a3-4f46a16e4946.jpg?1755290097",
    },
    {
      "name": "Plains",
      "url":
          "https://cards.scryfall.io/normal/front/4/0/4069fb4a-8ee1-41ef-ab93-39a8cc58e0e5.jpg?1755290075",
    },
    {
      "name": "Command Tower",
      "url":
          "https://cards.scryfall.io/normal/front/8/5/85eb4b03-305b-45a4-82e5-5fcd586cc744.jpg?1755356081",
    },
    {
      "name": "Arcane Signet",
      "url":
          "https://cards.scryfall.io/normal/front/3/d/3d994115-378d-4685-a5dc-e448831da434.jpg?1755356098",
    },
    {
      "name": "Sol Ring",
      "url":
          "https://cards.scryfall.io/normal/front/e/e/ee6e5a35-fe21-4dee-b0ef-a8f2841511ad.jpg?1752944480",
    },
    {
      "name": "Swords to Plowshares",
      "url":
          "https://cards.scryfall.io/normal/front/0/e/0e7ff4dc-af63-4342-9a44-d059e62bd14c.jpg?1752944384",
    },
    {
      "name": "Laelia, the Blade Reforged",
      "url":
          "https://cards.scryfall.io/normal/front/a/f/afeb2fe4-f0ef-4366-a568-c36b538f0196.jpg?1717013677",
    },
    {
      "name": "Vega, the Watcher",
      "url":
          "https://cards.scryfall.io/normal/front/2/8/28fced7f-3078-4a54-8f76-0ef14c732e97.jpg?1631051983",
    },
    {
      "name": "Party Thrasher",
      "url":
          "https://cards.scryfall.io/normal/front/b/7/b7f8bb8d-c46a-4531-9525-6981a222b468.jpg?1717012244",
    },
    {
      "name": "Talisman of Creativity",
      "url":
          "https://cards.scryfall.io/normal/front/b/f/bfe00640-e775-4b2e-91a8-081c7ec0125c.jpg?1743207377",
    },
    {
      "name": "Exotic Orchard",
      "url":
          "https://cards.scryfall.io/normal/front/e/8/e86174cd-0291-4fca-8e22-2d2b6f921460.jpg?1752945319",
    },
    {
      "name": "Expressive Iteration",
      "url":
          "https://cards.scryfall.io/normal/front/4/5/45e92d69-0684-4a57-8c1c-bbf742bd8a23.jpg?1743207125",
    },
    {
      "name": "Path to Exile",
      "url":
          "https://cards.scryfall.io/normal/front/a/7/a7aed564-2d2d-42c4-bf11-812bc1a0284c.jpg?1712354092",
    },
    {
      "name": "Spider-Man 2099",
      "url":
          "https://cards.scryfall.io/normal/front/2/a/2a72c7e7-34f5-4cb0-9959-35516e398e49.jpg?1757377876",
    },
    {
      "name": "Professional Face-Breaker",
      "url":
          "https://cards.scryfall.io/normal/front/4/2/42acbf52-b137-44f0-a815-2817fe8d2da2.jpg?1664411677",
    },
    {
      "name": "Sacred Foundry",
      "url":
          "https://cards.scryfall.io/normal/front/8/b/8b4e2642-3c87-4708-b9b4-2e7f7359ac7d.jpg?1752947600",
    },
    {
      "name": "Talisman of Conviction",
      "url":
          "https://cards.scryfall.io/normal/front/e/f/efeafc9d-a953-4915-8342-725836d0f645.jpg?1743207371",
    },
    {
      "name": "Light Up the Stage",
      "url":
          "https://cards.scryfall.io/normal/front/9/1/912b94c9-7200-452d-940f-df0a7cceb377.jpg?1726284958",
    },
    {
      "name": "Etali, Primal Storm",
      "url":
          "https://cards.scryfall.io/normal/front/b/6/b6af9894-95b5-4c8e-902f-a9ba70f02e4a.jpg?1730489317",
    },
    {
      "name": "Kami of Celebration",
      "url":
          "https://cards.scryfall.io/normal/front/b/d/bda67054-bbd8-4979-801a-a5e9ca335f49.jpg?1651655351",
    },
    {
      "name": "Interdimensional Web Watch",
      "url":
          "https://cards.scryfall.io/normal/front/8/7/87a8e112-e72f-413f-88a3-e7ce72c2ec53.jpg?1757378025",
    },
    {
      "name": "Steam Vents",
      "url":
          "https://cards.scryfall.io/normal/front/b/6/b66daa94-d367-4812-9f18-f35378c1febb.jpg?1759144847",
    },
    {
      "name": "Sulfur Falls",
      "url":
          "https://cards.scryfall.io/normal/front/2/5/258b1cc2-ce3c-4219-808c-812548a7dd12.jpg?1752945534",
    },
    {
      "name": "Quintorius Kand",
      "url":
          "https://cards.scryfall.io/normal/front/4/3/4382fa49-9e34-45b3-8495-4916dcd995ec.jpg?1701346165",
    },
    {
      "name": "Clifftop Retreat",
      "url":
          "https://cards.scryfall.io/normal/front/f/7/f795f6fd-eac9-4c6d-90f5-bc475c8d69ac.jpg?1752945284",
    },
    {
      "name": "Hallowed Fountain",
      "url":
          "https://cards.scryfall.io/normal/front/e/0/e056b55f-82ed-4fe0-ab0c-bb20fa4a218a.jpg?1759144845",
    },
    {
      "name": "Wild-Magic Sorcerer",
      "url":
          "https://cards.scryfall.io/normal/front/b/5/b5de7331-d0c6-46a5-b08d-0e032db63223.jpg?1674142192",
    },
    {
      "name": "Eruth, Tormented Prophet",
      "url":
          "https://cards.scryfall.io/normal/front/9/f/9f764077-df2d-4ac7-b507-2c8e08386d49.jpg?1643594095",
    },
    {
      "name": "Talisman of Progress",
      "url":
          "https://cards.scryfall.io/normal/front/9/d/9d6a5ed4-54b3-4660-8d41-953336f2fe74.jpg?1743207397",
    },
    {
      "name": "Araña, Heart of the Spider",
      "url":
          "https://cards.scryfall.io/normal/front/b/0/b02bfa0e-f761-45e1-b35c-f44ff7c5d0e8.jpg?1757377611",
    },
    {
      "name": "Urianger Augurelt",
      "url":
          "https://cards.scryfall.io/normal/front/4/4/44d44107-da15-41b9-8dfb-6335c1cbd83a.jpg?1748704548",
    },
    {
      "name": "Charred Foyer // Warped Space",
      "url":
          "https://cards.scryfall.io/normal/front/a/1/a128e6d1-b90f-45a1-b587-f8c29bd0ec8c.jpg?1726867813",
    },
    {
      "name": "Delayed Blast Fireball",
      "url":
          "https://cards.scryfall.io/normal/front/e/5/e59903e3-a344-4218-9d41-8b19a9bc8311.jpg?1674140946",
    },
    {
      "name": "Passionate Archaeologist",
      "url":
          "https://cards.scryfall.io/normal/front/b/d/bd5bbfa6-e5f4-413d-b132-ebae32d38657.jpg?1674140763",
    },
    {
      "name": "Wild Wasteland",
      "url":
          "https://cards.scryfall.io/normal/front/c/a/ca1024d6-c5f1-48f5-9081-fb90d0c46fdb.jpg?1708742249",
    },
    {
      "name": "Glacial Fortress",
      "url":
          "https://cards.scryfall.io/normal/front/a/1/a1fc8d86-b118-46e3-92a5-8cbf2ca282f7.jpg?1752945328",
    },
    {
      "name": "Mystic Monastery",
      "url":
          "https://cards.scryfall.io/normal/front/9/f/9fd41ad5-6b36-482e-8305-bbc709668470.jpg?1752945402",
    },
    {
      "name": "Reckless Impulse",
      "url":
          "https://cards.scryfall.io/normal/front/6/9/6943c07f-ab0d-4f5a-bbe9-c0a83dc98546.jpg?1643591880",
    },
    {
      "name": "Wrenn's Resolve",
      "url":
          "https://cards.scryfall.io/normal/front/9/a/9a47999c-12d5-4e1a-a9c1-40a1757007f1.jpg?1682204603",
    },
    {
      "name": "Cori Mountain Monastery",
      "url":
          "https://cards.scryfall.io/normal/front/9/3/9312821a-2059-4f44-9b20-c9522b827e38.jpg?1743204997",
    },
    {
      "name": "Pia Nalaar, Consul of Revival",
      "url":
          "https://cards.scryfall.io/normal/front/0/a/0ae89461-4bce-4b49-b875-03afc2469fe7.jpg?1684340810",
    },
    {
      "name": "Raugrin Triome",
      "url":
          "https://cards.scryfall.io/normal/front/0/2/02138fbb-3962-4348-8d31-faaefba0b8b2.jpg?1591228666",
    },
    {
      "name": "Heroes' Hangout",
      "url":
          "https://cards.scryfall.io/normal/front/4/1/4148d7e8-6371-468c-858b-35254995409a.jpg?1757377271",
    },
    {
      "name": "Shivan Reef",
      "url":
          "https://cards.scryfall.io/normal/front/7/2/72bba14a-c813-49c8-bf73-f41e1bdc1099.jpg?1752945498",
    },
    {
      "name": "Training Center",
      "url":
          "https://cards.scryfall.io/normal/front/7/8/78a39d22-5e3b-4ba0-b728-dbf16b61fc8f.jpg?1690000040",
    },
    {
      "name": "Flooded Strand",
      "url":
          "https://cards.scryfall.io/normal/front/8/f/8f85e12c-196b-4459-b81f-0c9c854e9f57.jpg?1717012985",
    },
    {
      "name": "Arid Mesa",
      "url":
          "https://cards.scryfall.io/normal/front/2/5/25ac5405-df7b-4097-914a-022cb18e20d4.jpg?1738703645",
    },
    {
      "name": "Spider-Verse",
      "url":
          "https://cards.scryfall.io/normal/front/f/8/f8779eb2-1210-430d-8d42-3077053441ee.jpg?1757377373",
    },
    {
      "name": "Ultimate Magic: Holy",
      "url":
          "https://cards.scryfall.io/normal/front/8/f/8fdb8414-2f08-42fb-ae0a-c7f0af1e144e.jpg?1748704311",
    },
    {
      "name": "Battlefield Forge",
      "url":
          "https://cards.scryfall.io/normal/front/6/e/6ef04c87-8d34-49af-8b79-72e460daf71c.jpg?1752944487",
    },
    {
      "name": "Fellwar Stone",
      "url":
          "https://cards.scryfall.io/normal/front/c/e/ce55e00c-cd95-48eb-986e-edf5125f3534.jpg?1743207310",
    },
    {
      "name": "Inti, Seneschal of the Sun",
      "url":
          "https://cards.scryfall.io/normal/front/f/a/fa7a55aa-ae61-4933-b7a4-dcc55dac6fcd.jpg?1699044306",
    },
    {
      "name": "Bonehoard Dracosaur",
      "url":
          "https://cards.scryfall.io/normal/front/2/2/2220ed60-3f8f-4dd2-8319-6a06896a5350.jpg?1699044226",
    },
    {
      "name": "Scalding Tarn",
      "url":
          "https://cards.scryfall.io/normal/front/7/1/71e491c5-8c07-449b-b2f1-ffa052e6d311.jpg?1738703652",
    },
    {
      "name": "Spectator Seating",
      "url":
          "https://cards.scryfall.io/normal/front/d/c/dcf3140f-d5c8-45ff-8be4-622b1a129b3d.jpg?1689999977",
    },
    {
      "name": "Glimpse the Impossible",
      "url":
          "https://cards.scryfall.io/normal/front/1/3/133ad0dd-5b61-4c38-9264-0b0e75b95d95.jpg?1717012201",
    },
    {
      "name": "The Lost and the Damned",
      "url":
          "https://cards.scryfall.io/normal/front/9/a/9a53cf96-b47f-48f0-b9cc-3330ae546a87.jpg?1677541655",
    },
    {
      "name": "Stormcarved Coast",
      "url":
          "https://cards.scryfall.io/normal/front/2/a/2a91991f-4340-45a7-ba04-0001de9581e0.jpg?1736468693",
    },
    {
      "name": "Plargg and Nassari",
      "url":
          "https://cards.scryfall.io/normal/front/1/7/179a0525-a142-46f6-9b5b-06a2fbb25556.jpg?1684340598",
    },
    {
      "name": "Sea of Clouds",
      "url":
          "https://cards.scryfall.io/normal/front/d/4/d4fb722f-40af-4bd1-b660-e8186b98f233.jpg?1674138237",
    },
    {
      "name": "Counterspell",
      "url":
          "https://cards.scryfall.io/normal/front/4/f/4f616706-ec97-4923-bb1e-11a69fbaa1f8.jpg?1751282477",
    },
    {
      "name": "Blasphemous Act",
      "url":
          "https://cards.scryfall.io/normal/front/f/b/fbeeb7d0-cda8-414b-82d3-a83f1883bdd2.jpg?1752944720",
    },
    {
      "name": "Cait Sith, Fortune Teller",
      "url":
          "https://cards.scryfall.io/normal/front/3/e/3e0f6c53-6bbf-4d4c-bbbf-4dab22297527.jpg?1748704391",
    },
    {
      "name": "Opera Love Song",
      "url":
          "https://cards.scryfall.io/normal/front/0/3/0343916d-1b65-4e95-aef1-e72dbcebf0c4.jpg?1748706312",
    },
    {
      "name": "Spider-Punk",
      "url":
          "https://cards.scryfall.io/normal/front/0/b/0bd41879-fcd4-4211-9b98-47e7cdba5399.jpg?1757377366",
    },
    {
      "name": "Birgi, God of Storytelling",
      "url":
          "https://cards.scryfall.io/normal/front/4/4/44657ab1-0a6a-4a5f-9688-86f239083821.jpg?1631048969",
    },
    {
      "name": "Adarkar Wastes",
      "url":
          "https://cards.scryfall.io/normal/front/4/2/42e0aa15-639a-4e88-9bd8-ce5e7c7d7649.jpg?1752945219",
    },
    {
      "name": "Sword of Forge and Frontier",
      "url":
          "https://cards.scryfall.io/normal/front/2/d/2daa3621-8a2c-4b4b-87ac-f981192a0567.jpg?1675957256",
    },
    {
      "name": "Saw It Coming",
      "url":
          "https://cards.scryfall.io/normal/front/8/7/877a1bb9-5eae-453a-bec0-a9de20ea6815.jpg?1631047574",
    },
    {
      "name": "Sage of the Beyond",
      "url":
          "https://cards.scryfall.io/normal/front/2/2/226a4c5d-bf49-40d8-a7a4-341c18029634.jpg?1713370579",
    },
    {
      "name": "Commander Liara Portyr",
      "url":
          "https://cards.scryfall.io/normal/front/9/a/9ac8b247-455e-4a3f-9f88-b20918c36cc3.jpg?1674137467",
    },
    {
      "name": "Ragavan, Nimble Pilferer",
      "url":
          "https://cards.scryfall.io/normal/front/a/9/a9738cda-adb1-47fb-9f4c-ecd930228c4d.jpg?1681963138",
    },
    {
      "name": "Chaos Warp",
      "url":
          "https://cards.scryfall.io/normal/front/d/4/d4372203-b930-4e6e-a351-e5b4581eb72b.jpg?1752944413",
    },
    {
      "name": "Sundown Pass",
      "url":
          "https://cards.scryfall.io/normal/front/1/2/12ca1b4f-3e98-4ad4-93fe-c4c2de09aa58.jpg?1736468697",
    },
    {
      "name": "An Offer You Can't Refuse",
      "url":
          "https://cards.scryfall.io/normal/front/a/8/a829747f-cf9b-4d81-ba66-9f0630ed4565.jpg?1730489199",
    },
    {
      "name": "Nalfeshnee",
      "url":
          "https://cards.scryfall.io/normal/front/b/7/b7717617-706a-4338-a207-dd8c08feb1c3.jpg?1674140963",
    },
    {
      "name": "Boros Charm",
      "url":
          "https://cards.scryfall.io/normal/front/e/0/e0d8c9f6-cbbd-4694-b100-01cfb81036cc.jpg?1736305704",
    },
    {
      "name": "Generous Gift",
      "url":
          "https://cards.scryfall.io/normal/front/f/c/fc70e127-ffc8-45ed-9ca3-7f9f926ac4d5.jpg?1700321873",
    },
    {
      "name": "Bohn, Beguiling Balladeer",
      "url":
          "https://cards.scryfall.io/normal/front/6/e/6e779a16-7528-49f4-8304-502bb603c15b.jpg?1736769919",
    },
    {
      "name": "Swiftfoot Boots",
      "url":
          "https://cards.scryfall.io/normal/front/1/9/1969b151-3192-4d35-80ca-c4e180601ec8.jpg?1743207367",
    },
    {
      "name": "Ignite the Future",
      "url":
          "https://cards.scryfall.io/normal/front/5/8/58e82d3c-a7ec-4e0d-a17e-51ebd2f3f331.jpg?1674142027",
    },
    {
      "name": "Deserted Beach",
      "url":
          "https://cards.scryfall.io/normal/front/c/8/c819de09-dac2-407a-98c8-775865e9bdf8.jpg?1736468668",
    },
    {
      "name": "Urabrask, Heretic Praetor",
      "url":
          "https://cards.scryfall.io/normal/front/d/9/d9a4ec18-1da4-43c6-a79a-03fbd4aef3db.jpg?1664411925",
    },
    {
      "name": "Izzet Signet",
      "url":
          "https://cards.scryfall.io/normal/front/2/c/2c747a97-9070-4c1e-b7b7-52637fbb30e1.jpg?1743207322",
    },
    {
      "name": "Chimil, the Inner Sun",
      "url":
          "https://cards.scryfall.io/normal/front/2/7/27a1bfb5-ddfc-49cf-baa3-5d1958d2067a.jpg?1699044596",
    },
    {
      "name": "Shadow of the Goblin",
      "url":
          "https://cards.scryfall.io/normal/front/8/5/854b6898-c480-435b-8952-a077c7977cec.jpg?1757377329",
    },
    {
      "name": "Prairie Stream",
      "url":
          "https://cards.scryfall.io/normal/front/f/a/fa0af5ea-e9e1-4247-bde2-759c2653fc00.jpg?1743207688",
    },
    {
      "name": "Valakut Exploration",
      "url":
          "https://cards.scryfall.io/normal/front/1/8/18cb7bf6-9c7c-4e62-a678-7b75862e2f64.jpg?1604263135",
    },
    {
      "name": "Flaming Tyrannosaurus",
      "url":
          "https://cards.scryfall.io/normal/front/0/b/0bc8ecfd-7388-4725-8c58-bed2cc61400f.jpg?1696636630",
    },
    {
      "name": "SP//dr, Piloted by Peni",
      "url":
          "https://cards.scryfall.io/normal/front/c/4/c47c1d83-e76d-4939-9ed6-05a9e709dea1.jpg?1758986794",
    },
    {
      "name": "The Key to the Vault",
      "url":
          "https://cards.scryfall.io/normal/front/1/6/166814af-a444-4a62-937e-7491673d9387.jpg?1712355445",
    },
    {
      "name": "Lightning Greaves",
      "url":
          "https://cards.scryfall.io/normal/front/8/b/8b59b12c-fde5-4f19-a357-e09f06f490cc.jpg?1743206077",
    },
    {
      "name": "Surge of Brilliance",
      "url":
          "https://cards.scryfall.io/normal/front/0/0/0001c639-8bd0-426f-89cb-4ca61f3cc054.jpg?1696636586",
    },
    {
      "name": "Tavern Brawler",
      "url":
          "https://cards.scryfall.io/normal/front/b/0/b07f8fc3-83a5-4e0a-b87f-ce415292c790.jpg?1674136784",
    },
    {
      "name": "Lae'zel, Vlaakith's Champion",
      "url":
          "https://cards.scryfall.io/normal/front/1/a/1a93f587-ab72-42da-88c4-31af1c9cdf1b.jpg?1674135140",
    },
    {
      "name": "Chandra, Torch of Defiance",
      "url":
          "https://cards.scryfall.io/normal/front/2/e/2eac0eaa-55b2-444a-863d-c66769aab4ee.jpg?1690004652",
    },
    {
      "name": "Boros Signet",
      "url":
          "https://cards.scryfall.io/normal/front/4/9/49c37c0e-d363-4033-a069-710241cd9923.jpg?1743207285",
    },
    {
      "name": "Ensnared by the Mara",
      "url":
          "https://cards.scryfall.io/normal/front/1/1/11454c82-3f1d-4456-8857-0dcb01d34298.jpg?1696636630",
    },
  ];

  List<Map<String, String>> deck = [];

  @override
  void initState() {
    for (int i = 0; i < cardData.length; i++) {
      _swipeItems.add(
        SwipeItem(
          content: CardWidget(url: cardData[i]['url']!),
          likeAction: () {
            setState(() {
              deck.add(cardData[i]);
            });
          },
          nopeAction: () {},
          superlikeAction: () {},
          onSlideUpdate: (SlideRegion? region) async {},
        ),
      );
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(widget.title!)),
      body: Row(
        children: [
          Expanded(
            child: Card(
              child: Column(
                children: [
                  Text("Commander:"),
                  Text(commander['name'] ?? ''),

                  CardWidget(url: commander['url'] ?? ''),
                ],
              ),
            ),
          ),
          Card(
            child: Container(
              constraints: BoxConstraints(maxWidth: 1000),
              child: SwipeCards(
                matchEngine: _matchEngine!,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    child: _swipeItems[index].content,
                  );
                },
                onStackFinished: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Stack Finished"),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                },
                itemChanged: (SwipeItem item, int index) {},
                leftSwipeAllowed: true,
                rightSwipeAllowed: true,
                upSwipeAllowed: false,
                fillSpace: true,
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: Column(
                children: [
                  Text("Deck"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: deck.length / 99,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.pink,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('${deck.length} / 99'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: deck.length,
                      itemBuilder: (context, index) {
                        final card = deck[index];
                        return ListTile(
                          leading: Image.network(
                            card['url'] ?? '',
                            width: 40,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                          title: Text(card['name'] ?? ''),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
