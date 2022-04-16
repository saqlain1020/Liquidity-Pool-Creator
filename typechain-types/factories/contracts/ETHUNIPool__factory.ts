/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type {
  ETHUNIPool,
  ETHUNIPoolInterface,
} from "../../contracts/ETHUNIPool";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "previousOwner",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "OwnershipTransferred",
    type: "event",
  },
  {
    inputs: [],
    name: "owner",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "renounceOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newOwner",
        type: "address",
      },
    ],
    name: "transferOwnership",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "uniswapAddress",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
];

const _bytecode =
  "0x6080604052731f9840a85d5af5bf1d1762f925bdaddc4201f984600160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555034801561006557600080fd5b5061008261007761008760201b60201c565b61008f60201b60201c565b610153565b600033905090565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050816000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b61054c806101626000396000f3fe608060405234801561001057600080fd5b506004361061004c5760003560e01c80630e2feb0514610051578063715018a61461006f5780638da5cb5b14610079578063f2fde38b14610097575b600080fd5b6100596100b3565b604051610066919061038e565b60405180910390f35b6100776100d9565b005b610081610161565b60405161008e919061038e565b60405180910390f35b6100b160048036038101906100ac91906103da565b61018a565b005b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b6100e1610281565b73ffffffffffffffffffffffffffffffffffffffff166100ff610161565b73ffffffffffffffffffffffffffffffffffffffff1614610155576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161014c90610464565b60405180910390fd5b61015f6000610289565b565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b610192610281565b73ffffffffffffffffffffffffffffffffffffffff166101b0610161565b73ffffffffffffffffffffffffffffffffffffffff1614610206576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004016101fd90610464565b60405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1603610275576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040161026c906104f6565b60405180910390fd5b61027e81610289565b50565b600033905090565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff169050816000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508173ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a35050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b60006103788261034d565b9050919050565b6103888161036d565b82525050565b60006020820190506103a3600083018461037f565b92915050565b600080fd5b6103b78161036d565b81146103c257600080fd5b50565b6000813590506103d4816103ae565b92915050565b6000602082840312156103f0576103ef6103a9565b5b60006103fe848285016103c5565b91505092915050565b600082825260208201905092915050565b7f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e6572600082015250565b600061044e602083610407565b915061045982610418565b602082019050919050565b6000602082019050818103600083015261047d81610441565b9050919050565b7f4f776e61626c653a206e6577206f776e657220697320746865207a65726f206160008201527f6464726573730000000000000000000000000000000000000000000000000000602082015250565b60006104e0602683610407565b91506104eb82610484565b604082019050919050565b6000602082019050818103600083015261050f816104d3565b905091905056fea2646970667358221220a411a7481e63e9749e05dc9ca87b81d101e99437b202c841f82afd9d9083707464736f6c634300080d0033";

type ETHUNIPoolConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: ETHUNIPoolConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class ETHUNIPool__factory extends ContractFactory {
  constructor(...args: ETHUNIPoolConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<ETHUNIPool> {
    return super.deploy(overrides || {}) as Promise<ETHUNIPool>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): ETHUNIPool {
    return super.attach(address) as ETHUNIPool;
  }
  override connect(signer: Signer): ETHUNIPool__factory {
    return super.connect(signer) as ETHUNIPool__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): ETHUNIPoolInterface {
    return new utils.Interface(_abi) as ETHUNIPoolInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ETHUNIPool {
    return new Contract(address, _abi, signerOrProvider) as ETHUNIPool;
  }
}
