
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//importanto um contrato de interface que define um conjunto de funções que devem ser implementadas por outro contrato, fornecendo uma interface comum.
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    
    //Pegando o preço do par de moedas no adress e conectando a ABI
    function getPrice() internal view returns (uint256){
        //Adress 0x694AA1769357215DE4FAC081bf1f309aDC325306

        //ABI
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        //IMPORTANDO A FUNÇÃO DATAFEED
        (    
        /* uint80 roundID */,
        int answer, // <- Esse é o preço
            /* uint startedAt */, //<- Usando a desestruturação para ignorar parametros que não serão utilizados
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = priceFeed.latestRoundData(); //recupera o preço mais recente da criptomoeda

          require(answer > 0, "Invalid price data"); // Evita valores negativos

        return uint256(answer) * 1e10; // Converte de 8 para 18 casas decimais porque o msg.value da nossa função fund é somente compatível com Wei
    }

    //Converte o valor 
    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice(); //Retorna o preço do Ethereum em dólares 

        //A multiplicação ethPrice * ethAmount inicialmente resulta em um número extremamente grande (Wei × USD/ETH), que precisa ser ajustado dividindo por 1e18 para que o resultado final esteja na escala correta de dólares (USD).
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; 
        
        return ethAmountInUsd; //retornando o preço em dolares

    }

    //retornando a version da interface
    function getVersion() internal view returns (uint256) {
        //retornando a version do adress do par USD/ETH
       return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}