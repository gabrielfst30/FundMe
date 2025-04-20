// Obter fundos dos usuários neste contrato e sacar fundos do proprietário
// Definir valor mínimo de financiamento em USD

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

//843080
//822340
//822340

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    //variáveis constantes tem uma nomenclatura diferente
    //elas economizam mais gás
    uint256 public constant MINIMUN_USD = 5e18;

    //matriz de endereços de usuários que financiaram o projeto
    address[] public funders;
    //mapeando o valor recebido pelos endereços
    //financiador => quantia financiada
    mapping(address => uint256) public addressToAmountFunded;

    //variável para armazenar o address do implementador do contrato
    //variável imutavel economiza também mais gás
    address public immutable i_owner;

    //Essa função será chamada imediatamente quando o contrato for implementado
    constructor() {
        i_owner = msg.sender; //definindo o owner como o usuário que implementou o contrato
    }

    //Envia dinheiro para nosso contrato
    //Tem um valor minimo de envio
    function fund() public payable {
        //A palavra chave "payable" faz da função pagável

        //1. Definindo valor mínimo obrigatório utilizando o require e o msg.value
        //2. Na mensagem de condição negativa do require, para acentuação é necessário colocar o unicode antes da string

        //msg.value é sempre mostrado em WEI (18 casas decimais)
        require(
            msg.value.getConversionRate() >= MINIMUN_USD,
            unicode"Você não tem USD suficiente"
        );

        //mandando o endereço do usuário para nossa matriz de endereços
        funders.push(msg.sender);
        //atualizando o saldo do endereço
        //o colchetes serve para acessar valores dentro do mapping
        addressToAmountFunded[msg.sender] += msg.value; //adress + value
    }

    //sacar dinheiro dos financiadores
    function withdrawn() public onlyOwner {
        //verificando se existe financiadores
        require(
            funders.length > 0,
            unicode"Sem financiadores, impossível sacar alguma quantia"
        );
        //for (start index, end index, count)
        //se o indice que é 0 for menor que o tamanho da matriz de funders, incremente para percorrer
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            //acessando o endereço do financiador
            address funder = funders[funderIndex];
            //zerando conta do financiador acessando seu endereço e passando o value de 0 (simulando um saque)
            addressToAmountFunded[funder] = 0;
        }

        //criando novos endereços de tamanho 0 para substituir o array original- eliminando todos os endereços
        funders = new address[](0);

        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    //modificadores de função, servem para fazer validações em uma função
    modifier onlyOwner() {
        //condição para saber se é o implementador ou não
        // require(i_owner == msg.sender, unicode"Apenas o dono do contrato pode sacar o valor!");

        //Erros personalizados que economizam mais gás
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _; //<- esse modificador executa a função que esta sendo modificada"
    }

    //o receive serve para quando o contrato receber um ETH sem chamar nenhuma função
    receive() external payable {
        fund();
    }

    //o fallback serve para quando o contrato recebe dados inválidos ou desconhecidos
    fallback() external payable { 
        fund();
    }
}
