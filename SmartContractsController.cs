using System.Numerics;
using Microsoft.AspNetCore.Mvc;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.Contracts;
using Nethereum.Hex.HexTypes;
using Nethereum.Web3;
using Nethereum.Web3.Accounts;

namespace Web3Example.Controllers;

[ApiController]
[Route("[controller]/[action]")]
public class SmartContractsController : ControllerBase
{
    private readonly Web3 _web3; 

    public SmartContractsController()
    {
        var privateKey = Environment.GetEnvironmentVariable("TESTKEY");
        var account = new Account(privateKey);
        //var rpcUrl = "https://sepolia.infura.io/v3/";
        var rpcUrl = "https://endpoints.omniatech.io/v1/eth/sepolia/public";
        //var rpcUrl = "https://rpc.sepolia.org";
        _web3 = new Web3(account, rpcUrl); 
    }

    [HttpGet]
    public async Task<string> BalanceInWei(string address)
    {
        var balance = await _web3.Eth.GetBalance.SendRequestAsync(address);
        Console.WriteLine($"Balance in Wei: {balance.Value}");
        return balance.ToString();
    }
    
    [HttpGet]
    public async Task<decimal> BalanceInEth(string address)
    {
        var balanceWei = await _web3.Eth.GetBalance.SendRequestAsync(address);
        var balanceEth = Web3.Convert.FromWei(balanceWei.Value);
        Console.WriteLine($"Balance in Ether: {balanceEth}");
        return balanceEth;
    }

    [HttpPost]
    public async Task Transfer([FromBody]TransferRequest request)
    {
        var transaction = await _web3.Eth.GetEtherTransferService()
            .TransferEtherAndWaitForReceiptAsync(request.Address, request.AmountEth);
        Console.WriteLine($"Transferred {request.AmountEth} ETH to {request.Address}. Transaction hash: {transaction.TransactionHash}");
    }

    [HttpPost]
    public async Task ChangeSalary([FromBody] ChangeSalaryRequest request)
    {
        const string salaryContractAddress = "0xd3B3e5D4444E12B7F785476B385Fc8B343336Ce1";

        var changeSalaryMessage = new ChangeSalaryMessage
        {
            Address = request.Address,
            SalaryInWei = Web3.Convert.ToWei(request.NewSalaryInEth)
        };
        var transactionReceipt = await _web3.Eth.GetContractTransactionHandler<ChangeSalaryMessage>()
            .SendRequestAndWaitForReceiptAsync(salaryContractAddress, changeSalaryMessage);
        Console.WriteLine($"Changed salary of {request.Address} to {request.NewSalaryInEth} ETH. Transaction hash: {transactionReceipt.TransactionHash}");
    }
}

public record TransferRequest(string Address, decimal AmountEth);

public record ChangeSalaryRequest(string Address, decimal NewSalaryInEth);

[Function("changeSalary")]
public class ChangeSalaryMessage : FunctionMessage
{
    [Parameter("address", "_employee", 1)]
    public string Address { get; set; }

    [Parameter("uint256", "_salaryInWei", 2)]
    public BigInteger SalaryInWei { get; set; }
}
