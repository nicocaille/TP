# Introduction aux Oracles Chainlink - Accès aux Données Externes

## Objectifs

- Comprendre le fonctionnement des oracles Chainlink
- Manipuler des données externes via les smart contracts
- Mettre en pratique l’interaction avec le réseau Chainlink

## Partie 1 : Préparation

Configuration de l’environnement

- Utilisation de [Remix IDE](https://remix.ethereum.org/)
- Installation de MetaMask (déjà fait lors du TP1)
- Connexion au réseau de test BNB Chain depuis Remix IDE
- Obtention de tokens LINK de test via le faucet Chainlink

## Partie 2 : Smart Contract

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract CryptoPriceConsumer {
    AggregatorV3Interface internal priceFeed;

    // Adresse du Price Feed BNB/USD sur BNB Chain Testnet
    constructor() {
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
    }

    function getLatestPrice() public view returns (int) {
        (
            /* uint80 roundID */,
            int price,
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = priceFeed.latestRoundData();
        return price;
    }

    function getDecimals() public view returns (uint8) {
        return priceFeed.decimals();
    }
}
```

## Compilation et deploiement du Smart Contract

Suivez les étapes:

1. Copiez le code dans un nouveau fichier .sol
2. Sélectionnez le compilateur 0.8.7
3. Compilez le contrat
4. Allez dans l’onglet “Deploy & Run Transactions”
5. Sélectionnez “Injected Provider - MetaMask” comme environnement
6. Cliquez sur “Deploy”
7. Confirmez la transaction dans MetaMask

## Interaction avec le Smart Contract

1. Une fois déployé, le contrat apparaît dans la section “Deployed Contracts”
2. Cliquez sur “getLatestPrice”
3. Le prix BNB/USD s’affiche (attention aux décimaux)
4. Pour voir le nombre de décimaux, cliquez sur “getDecimals”

## Exercices Pratiques

### Exercice 1 : Multi-Price Feed

```javascript
contract MultiPriceConsumer {
    AggregatorV3Interface internal bnbUsdPriceFeed;
    AggregatorV3Interface internal btcUsdPriceFeed;

    constructor() {
        bnbUsdPriceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        btcUsdPriceFeed = AggregatorV3Interface(0x5741306c21795FdCBb9b265Ea0255F499DFe515C);
    }

    function getBNBPrice() public view returns (int) {
        (,int price,,,) = bnbUsdPriceFeed.latestRoundData();
        return price;
    }

    function getBTCPrice() public view returns (int) {
        (,int price,,,) = btcUsdPriceFeed.latestRoundData();
        return price;
    }
}
```

### Exercice 1bis : Multi-Price Advanced Feed

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract AdvancedMultiPriceConsumer {
    AggregatorV3Interface internal bnbUsdPriceFeed;
    AggregatorV3Interface internal btcUsdPriceFeed;
    AggregatorV3Interface internal ethUsdPriceFeed;

    mapping(string => AggregatorV3Interface) public priceFeeds;

    constructor() {
        priceFeeds["BNB"] = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        priceFeeds["BTC"] = AggregatorV3Interface(0x5741306c21795FdCBb9b265Ea0255F499DFe515C);
        priceFeeds["ETH"] = AggregatorV3Interface(0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7);
    }

    struct PriceData {
        int price;
        uint8 decimals;
        uint256 timestamp;
    }

    function getPriceData(string memory symbol) public view returns (PriceData memory) {
        require(address(priceFeeds[symbol]) != address(0), "Prix non disponible");

        AggregatorV3Interface priceFeed = priceFeeds[symbol];
        (
            ,
            int price,
            ,
            uint256 timestamp,
        ) = priceFeed.latestRoundData();

        return PriceData(
            price,
            priceFeed.decimals(),
            timestamp
        );
    }

    function convertPrice(string memory fromSymbol, string memory toSymbol, int256 amount)
        public
        view
        returns (int256)
    {
        PriceData memory fromPrice = getPriceData(fromSymbol);
        PriceData memory toPrice = getPriceData(toSymbol);

        return (amount * fromPrice.price) / toPrice.price;
    }
}
```

### Exercice 2 : Price Alert System

```javascript
contract PriceAlert {
    AggregatorV3Interface internal priceFeed;
    int public alertPrice;
    address public owner;

    event PriceThresholdMet(int currentPrice);

    constructor() {
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        owner = msg.sender;
    }

    function setAlertPrice(int _price) public {
        require(msg.sender == owner, "Only owner");
        alertPrice = _price;
    }

    function checkPrice() public returns (bool) {
        (,int price,,,) = priceFeed.latestRoundData();
        if (price >= alertPrice) {
            emit PriceThresholdMet(price);
            return true;
        }
        return false;
    }
}
```

### Exercice 2bis : Advanced Price Alert System

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract AdvancedPriceAlert {
    AggregatorV3Interface internal priceFeed;
    address public owner;

    struct Alert {
        int upperLimit;
        int lowerLimit;
        bool isActive;
        uint256 lastTriggered;
        uint256 cooldownPeriod;
    }

    mapping(address => Alert) public userAlerts;

    event AlertTriggered(
        address user,
        int currentPrice,
        int upperLimit,
        int lowerLimit,
        uint256 timestamp
    );

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function setAlert(
        int _upperLimit,
        int _lowerLimit,
        uint256 _cooldownPeriod
    ) external {
        require(_upperLimit > _lowerLimit, "Limites invalides");
        userAlerts[msg.sender] = Alert({
            upperLimit: _upperLimit,
            lowerLimit: _lowerLimit,
            isActive: true,
            lastTriggered: 0,
            cooldownPeriod: _cooldownPeriod
        });
    }

    function checkPriceAlert() external returns (bool) {
        Alert storage alert = userAlerts[msg.sender];
        require(alert.isActive, "Alerte non active");
        require(
            block.timestamp >= alert.lastTriggered + alert.cooldownPeriod,
            "Periode de recharge non ecoulee"
        );

        (
            ,
            int price,
            ,
            uint256 timestamp,
        ) = priceFeed.latestRoundData();

        if (price >= alert.upperLimit || price <= alert.lowerLimit) {
            alert.lastTriggered = block.timestamp;
            emit AlertTriggered(
                msg.sender,
                price,
                alert.upperLimit,
                alert.lowerLimit,
                timestamp
            );
            return true;
        }
        return false;
    }

    function getPrice() public view returns (int, uint8) {
        (
            ,
            int price,
            ,
            ,
        ) = priceFeed.latestRoundData();
        return (price, priceFeed.decimals());
    }

    function deactivateAlert() external {
        userAlerts[msg.sender].isActive = false;
    }

    function updateCooldownPeriod(uint256 _newPeriod) external {
        userAlerts[msg.sender].cooldownPeriod = _newPeriod;
    }
}
```

## Mini-projet

- Création d’une fonction permettant de suivre les variations de prix
- Implémentation d’une alerte si le prix dépasse un certain seuil

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceCalculator {
    mapping(string => AggregatorV3Interface) public priceFeeds;
    mapping(string => uint256[]) public historicalPrices;
    uint256 public constant PRICE_HISTORY_LENGTH = 10;

    constructor() {
        priceFeeds["BNB"] = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        priceFeeds["BTC"] = AggregatorV3Interface(0x5741306c21795FdCBb9b265Ea0255F499DFe515C);
        priceFeeds["ETH"] = AggregatorV3Interface(0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7);
    }

    function updatePriceHistory(string memory symbol) public {
        (,int price,,,) = priceFeeds[symbol].latestRoundData();

        if (historicalPrices[symbol].length >= PRICE_HISTORY_LENGTH) {
            // Décalage des prix
            for (uint i = 0; i < PRICE_HISTORY_LENGTH - 1; i++) {
                historicalPrices[symbol][i] = historicalPrices[symbol][i + 1];
            }
            historicalPrices[symbol][PRICE_HISTORY_LENGTH - 1] = uint256(price);
        } else {
            historicalPrices[symbol].push(uint256(price));
        }
    }

    function calculatePriceVariation(string memory symbol)
        public
        view
        returns (int256 percentage)
    {
        require(historicalPrices[symbol].length >= 2, "Pas assez d'historique");

        uint256 oldestPrice = historicalPrices[symbol][0];
        uint256 newestPrice = historicalPrices[symbol][historicalPrices[symbol].length - 1];

        percentage = int256(((newestPrice - oldestPrice) * 100) / oldestPrice);
    }

    function getMovingAverage(string memory symbol)
        public
        view
        returns (uint256)
    {
        require(historicalPrices[symbol].length > 0, "Pas d'historique");

        uint256 sum = 0;
        for (uint i = 0; i < historicalPrices[symbol].length; i++) {
            sum += historicalPrices[symbol][i];
        }

        return sum / historicalPrices[symbol].length;
    }

    function convertAmount(
        string memory fromSymbol,
        string memory toSymbol,
        uint256 amount
    ) public view returns (uint256) {
        (,int fromPrice,,,) = priceFeeds[fromSymbol].latestRoundData();
        (,int toPrice,,,) = priceFeeds[toSymbol].latestRoundData();

        uint8 fromDecimals = priceFeeds[fromSymbol].decimals();
        uint8 toDecimals = priceFeeds[toSymbol].decimals();

        // Normalisation des décimales
        uint256 normalizedAmount = amount * uint256(fromPrice) * (10 ** toDecimals);
        return normalizedAmount / (uint256(toPrice) * (10 ** fromDecimals));
    }
}

```

## Questions de Réflexion et Conclusion

1. Pourquoi utiliser un oracle décentralisé plutôt qu’une API classique?

Avantages des Oracles Décentralisés:

- La blockchain est un système fermé qui ne peut pas accéder directement aux données externes de manière sécurisée
- Les oracles décentralisés garantissent l’intégrité et la disponibilité des données, contrairement aux API centralisées qui représentent un point unique de défaillance
- Les données sont vérifiées par plusieurs nœuds indépendants avant d’être transmises à la blockchain, assurant leur authenticité

2. Quels sont les risques potentiels liés à l’utilisation des oracles?

Vulnérabilités Principales:

- Le problème de l’oracle (“Oracle Problem”) : risque de manipulation des données entre leur source et la blockchain
- Risques de latence dans la transmission des données critiques
- Possibilité de défaillance des sources de données sous-jacentes
- Coûts opérationnels plus élevés liés à la décentralisation

3. Comment Chainlink assure-t-il la fiabilité des données?

Architecture de Sécurité:

- Réseau de nœuds décentralisés qui agrègent les données de multiples sources
- Système de réputation des nœuds basé sur leur historique de performance
- Mécanisme de consensus qui compare les données de différents nœuds pour garantir leur exactitude
- Incitations économiques (staking de LINK) pour assurer l’honnêteté des nœuds validateurs
  Garanties Supplémentaires
  • Vérification cryptographique des données à chaque étape
  • Système d’agrégation qui élimine les valeurs aberrantes
  • Audits réguliers des smart contracts et des sources de données
  • Redondance multiple des sources de données et des nœuds validateurs

## Autres resources

[Chainlink demos](https://dev.chain.link/demos)
