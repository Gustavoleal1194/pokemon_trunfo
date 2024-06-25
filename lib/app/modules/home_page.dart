import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const MaterialApp(
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Pokemon? _pokemon1;
  Pokemon? _pokemon2;
  bool isLoading = true;
  bool player1CanFight = true;
  bool player2CanFight = false;
  int player1Reloads = 20;
  int player2Reloads = 20;
  String? _selectedAttributePlayer1;
  String? _selectedAttributePlayer2;
  bool _isPlayer1Turn = true;
  int _turnCount = 0;
  final int _maxTurns = 100;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    setState(() {
      _pokemon1 = null;
      _pokemon2 = null;
      isLoading = true;
      player1Reloads = 20;
      player2Reloads = 20;
      player1CanFight = true;
      player2CanFight = false;
    });

    await _fetchPokemonData();

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchPokemonData() async {
    final List<int> ids = [
      Random().nextInt(700) + 1,
      Random().nextInt(700) + 1,
    ];

    final List<Future<Pokemon>> futures = ids.map((id) async {
      final response =
          await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return Pokemon.fromJson(decoded);
      } else {
        throw Exception('Failed to load pokemon');
      }
    }).toList();

    final List<Pokemon> pokemonList = await Future.wait(futures);
    setState(() {
      _pokemon1 = pokemonList[0];
      _pokemon2 = pokemonList[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.blue,
          image: DecorationImage(
            image: AssetImage('assets/backgroundHome.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  const SizedBox(
                    height: 100,
                    width: 1000,
                    child: Center(
                      child: Text(
                        'Pokémon Battle',
                        style: TextStyle(
                          fontSize: 84,
                          color: Colors.yellow,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'HoltwoodOneSC-Regular',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPokemonContainer(_pokemon1, 1),
                        const SizedBox(
                          width: 400,
                          height: 250,
                          child: Text(
                            'VS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 108,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.red,
                              letterSpacing: 8.0,
                              color: Colors.red,
                              fontFamily: 'HoltwoodOneSC-Regular',
                            ),
                          ),
                        ),
                        _buildPokemonContainer(_pokemon2, 2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
      ),
    );
  }

  Widget _buildPokemonContainer(Pokemon? pokemon, int player) {
    int reloads = player == 1 ? player1Reloads : player2Reloads;
    return Container(
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 290,
            height: 220,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
              image: DecorationImage(
                image: const AssetImage('assets/pokebola.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.blueGrey.withOpacity(0.4),
                  BlendMode.dstATop,
                ),
              ),
            ),
            child: pokemon != null &&
                    (player == 1 ? player1CanFight : player2CanFight)
                ? Image.network(
                    pokemon.sprites!.frontDefault,
                    fit: BoxFit.contain,
                  )
                : const SizedBox(),
          ),
          Column(
            children: [
              Text(
                pokemon != null ? pokemon.name : '?????',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                  fontFamily: 'HoltwoodOneSC-Regular',
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                pokemon != null ? 'Height: ${pokemon.height} cm' : '?????',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.yellow,
                  fontFamily: 'HoltwoodOneSC-Regular',
                ),
              ),
              Text(
                pokemon != null ? 'Weight: ${pokemon.weight} kg' : '?????',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.yellow,
                  fontFamily: 'HoltwoodOneSC-Regular',
                ),
              ),
              Text(
                pokemon != null
                    ? 'Type(s): ${pokemon.types?.map((type) => type.name).join(", ")}'
                    : '?????',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.yellow,
                  fontFamily: 'HoltwoodOneSC-Regular',
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                'Base Stats:',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontFamily: 'HoltwoodOneSC-Regular',
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              if (pokemon != null &&
                  (player == 1 ? player1CanFight : player2CanFight))
                ...pokemon.stats!.map(
                  (stat) => Text(
                    '${stat.name}: ${stat.baseStat}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.yellow,
                      fontFamily: 'HoltwoodOneSC-Regular',
                    ),
                  ),
                ),
              const SizedBox(
                height: 8,
              ),
              if ((player == 1 && player1CanFight) ||
                  (player == 2 && player2CanFight))
                Column(
                  children: [
                    _buildAttributeDropdown(
                      player: player,
                      onChanged: (value) {
                        setState(() {
                          if (player == 1) {
                            _selectedAttributePlayer1 = value;
                          } else {
                            _selectedAttributePlayer2 = value;
                          }
                        });
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: 215,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _fightTurn(player);
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.gamepad,
                        ),
                        label: const Center(
                          child: Text(
                            'FIGHT',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'HoltwoodOneSC-Regular',
                              fontSize: 30,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          iconColor: Colors.red,
                          alignment: Alignment.centerLeft,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              Text(
                'Reloads: $reloads',
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.blue,
                  fontFamily: 'HoltwoodOneSC-Regular',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeDropdown({
    required int player,
    required ValueChanged<String?> onChanged,
  }) {
    final String? selectedAttribute =
        player == 1 ? _selectedAttributePlayer1 : _selectedAttributePlayer2;
    final List<String> attributes = [
      'HP',
      'Attack',
      'Defense',
      'Special-Attack',
      'Special-Defense',
      'Speed'
    ];

    return DropdownButton<String>(
        value: selectedAttribute,
        onChanged: onChanged,
        items: attributes.map((attribute) {
          return DropdownMenuItem<String>(
            value: attribute,
            child: Text(
              attribute,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                fontFamily: 'HoltwoodOneSC-Regular',
              ),
            ),
          );
        }).toList(),
        hint: const Text(
          "Select Atributte",
          style: TextStyle(
              color: Colors.blue, fontFamily: 'HoltwoodOneSC-Regular'),
        ));
  }

  void _fightTurn(int player) {
    String? selectedAttribute;
    int player1Value = 0;
    int player2Value = 0;

    if (player == 1) {
      selectedAttribute = _selectedAttributePlayer1;
    } else {
      selectedAttribute = _selectedAttributePlayer2;
    }

    if (selectedAttribute != null) {
      if (selectedAttribute == 'HP') {
        player1Value = _pokemon1!.stats![0].baseStat;
        player2Value = _pokemon2!.stats![0].baseStat;
      } else if (selectedAttribute == 'Attack') {
        player1Value = _pokemon1!.stats![1].baseStat;
        player2Value = _pokemon2!.stats![1].baseStat;
      } else if (selectedAttribute == 'Defense') {
        player1Value = _pokemon1!.stats![2].baseStat;
        player2Value = _pokemon2!.stats![2].baseStat;
      } else if (selectedAttribute == 'Special-Attack') {
        player1Value = _pokemon1!.stats![3].baseStat;
        player2Value = _pokemon2!.stats![3].baseStat;
      } else if (selectedAttribute == 'Special-Defense') {
        player1Value = _pokemon1!.stats![4].baseStat;
        player2Value = _pokemon2!.stats![4].baseStat;
      } else if (selectedAttribute == 'Speed') {
        player1Value = _pokemon1!.stats![5].baseStat;
        player2Value = _pokemon2!.stats![5].baseStat;
      }

      bool player1Wins = player1Value > player2Value;
      bool player2Wins = player2Value > player1Value;

      setState(() {
        _turnCount++;

        if ((player1Wins && player == 1) || (player2Wins && player == 2)) {
          if (player == 1) {
            player2CanFight = true;
          } else {
            player1CanFight = true;
          }
        } else {
          if (player == 1) {
            player2CanFight = true;
          } else {
            player1CanFight = true;
          }
        }

        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            if (player1Wins && player == 1) {
              player2Reloads--;
              player1Reloads++;
            } else if (player2Wins && player == 2) {
              player1Reloads--;
              player2Reloads++;
            } else if (player1Wins && player == 2) {
              player2Reloads--;
              player1Reloads++;
            } else if (player2Wins && player == 1) {
              player1Reloads--;
              player2Reloads++;
            } else {}

            if (player1Reloads <= 0 ||
                player2Reloads <= 0 ||
                _turnCount >= _maxTurns) {
              _endGame();
            } else {
              if (player1Wins && player == 1 || player2Wins && player == 2) {
                _isPlayer1Turn = player == 1;
                player1CanFight = _isPlayer1Turn;
                player2CanFight = !_isPlayer1Turn;
                _selectedAttributePlayer1 =
                    player == 1 ? null : _selectedAttributePlayer1;
                _selectedAttributePlayer2 =
                    player == 2 ? null : _selectedAttributePlayer2;
              } else {
                _isPlayer1Turn = !_isPlayer1Turn;
                player1CanFight = _isPlayer1Turn;
                player2CanFight = !_isPlayer1Turn;
                if (_isPlayer1Turn) {
                  _selectedAttributePlayer2 = null;
                } else {
                  _selectedAttributePlayer1 = null;
                }
              }

              _fetchPokemonData();
            }
          });
        });
      });
    }
  }

  void _endGame() {
    String winnerMessage;
    if (player1Reloads <= 0 && player2Reloads <= 0) {
      winnerMessage = 'Empate!';
    } else {
      winnerMessage =
          'Player ${player1Reloads <= 0 ? '2' : '1'} venceu com ${player1Reloads > 0 ? player1Reloads : player2Reloads} reloads restantes!';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(winnerMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
            ),
          ],
        );
      },
    );
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
    });
  }
}

class Pokemon {
  final String name;
  final int height;
  final double weight;
  final List<PokemonType>? types;
  final List<PokemonAbility>? abilities;
  final List<PokemonStat>? stats;
  final PokemonSprites? sprites;

  Pokemon({
    required this.name,
    required this.height,
    required this.weight,
    this.types,
    this.abilities,
    this.stats,
    this.sprites,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final List<PokemonType> types = (json['types'] as List)
        .map((type) => PokemonType.fromJson(type['type']))
        .toList();
    final List<PokemonAbility> abilities = (json['abilities'] as List)
        .map((ability) => PokemonAbility.fromJson(ability['ability']))
        .toList();
    final List<PokemonStat> stats = (json['stats'] as List)
        .map((stat) => PokemonStat.fromJson(stat))
        .toList();
    final PokemonSprites sprites = PokemonSprites.fromJson(json['sprites']);

    return Pokemon(
      name: json['name'],
      height: json['height'] * 10,
      weight: json['weight'] / 10,
      types: types,
      abilities: abilities,
      stats: stats,
      sprites: sprites,
    );
  }
}

class PokemonType {
  final String name;

  PokemonType({required this.name});

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(name: json['name']);
  }
}

class PokemonAbility {
  final String name;

  PokemonAbility({required this.name});

  factory PokemonAbility.fromJson(Map<String, dynamic> json) {
    return PokemonAbility(name: json['name']);
  }
}

class PokemonStat {
  final String name;
  final int baseStat;

  PokemonStat({required this.name, required this.baseStat});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']['name'],
      baseStat: json['base_stat'],
    );
  }
}

class PokemonSprites {
  final String frontDefault;

  PokemonSprites({required this.frontDefault});

  factory PokemonSprites.fromJson(Map<String, dynamic> json) {
    return PokemonSprites(frontDefault: json['front_default']);
  }
}
