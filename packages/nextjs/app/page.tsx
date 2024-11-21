"use client";

import Link from "next/link";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { Address } from "~~/components/scaffold-eth";
import { useState } from "react";

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const [recipient, setRecipient] = useState("");
  const [amount, setAmount] = useState("");

  // Retrieve the arbiter address from environment variables
  const arbiterAddress = process.env.NEXT_PUBLIC_ARBITER_ADDRESS;

  // Handle escrow creation
  const handleCreateEscrow = async (e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();

    try {
      if (!recipient || !amount) {
        throw new Error("Recipient and Amount are required");
      }

      if (!arbiterAddress) {
        throw new Error("Arbiter address is not defined in environment variables");
      }

      // Interact with the contract (replace this with your actual contract logic)
      console.log("Escrow created with:", { recipient, arbiterAddress, amount });
      alert("Escrow created successfully!");
    } catch (error) {
      console.error("Error creating escrow:", error);
      alert("Failed to create escrow. Check the console for details.");
    }
  };

  return (
    <>
      <div className="flex flex-col items-center flex-grow pt-10">
        {/* Header */}
        <header className="w-full px-5 py-4 bg-base-200 text-center">
          <h1 className="text-4xl font-bold">MULTIESCROW</h1>
          <p className="mt-2 text-sm">A decentralized escrow system for secure transactions</p>
          <div className="mt-4 flex items-center justify-center space-x-2">
            <p className="font-medium">Connected Address:</p>
            <Address address={connectedAddress} />
          </div>
        </header>

        {/* Dashboard */}
        <section className="w-full px-5 py-10">
          <h2 className="text-2xl font-bold text-center mb-6">Escrows Dashboard</h2>
          <div className="overflow-x-auto">
            <table className="table-auto w-full border-collapse border border-base-300">
              <thead className="bg-base-200">
                <tr>
                  <th className="border border-base-300 px-4 py-2">ID</th>
                  <th className="border border-base-300 px-4 py-2">State</th>
                  <th className="border border-base-300 px-4 py-2">Amount (ETH)</th>
                  <th className="border border-base-300 px-4 py-2">Actions</th>
                </tr>
              </thead>
              <tbody>
                {/* Replace with dynamic rows */}
                <tr>
                  <td className="border border-base-300 px-4 py-2">1</td>
                  <td className="border border-base-300 px-4 py-2">Awaiting Payment</td>
                  <td className="border border-base-300 px-4 py-2">1.5</td>
                  <td className="border border-base-300 px-4 py-2">
                    <button className="btn btn-primary btn-sm">Deposit</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>

        {/* Create Escrow */}
        <section className="w-full px-5 py-10 bg-base-100">
          <h2 className="text-2xl font-bold text-center mb-6">Create a New Escrow</h2>
          <form className="max-w-md mx-auto space-y-4">
            <input
              type="text"
              placeholder="Recipient Address"
              className="input input-bordered w-full"
              value={recipient}
              onChange={(e) => setRecipient(e.target.value)}
            />
            <input
              type="number"
              placeholder="Amount (ETH)"
              className="input input-bordered w-full"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
            />
            <button
              className="btn btn-primary w-full"
              onClick={handleCreateEscrow}
            >
              Create Escrow
            </button>
          </form>
        </section>
      </div>
    </>
  );
};

export default Home;
