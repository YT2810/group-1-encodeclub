"use client";

import React, { useCallback, useRef, useState } from "react";
import Link from "next/link";
import { Bars3Icon } from "@heroicons/react/24/outline";
import { RainbowKitCustomConnectButton } from "~~/components/scaffold-eth";
import { useOutsideClick } from "~~/hooks/scaffold-eth";

export const HeaderMenuLinks = () => {
  const menuLinks = [
    {
      label: "Home",
      href: "/",
    },
    {
      label: "Escrows",
      href: "/escrows",
    },
  ];

  return (
    <>
      {menuLinks.map(({ label, href }) => (
        <li key={href}>
          <Link
            href={href}
            passHref
            className="hover:bg-secondary hover:shadow-md focus:!bg-secondary py-1.5 px-3 text-sm rounded-full"
          >
            {label}
          </Link>
        </li>
      ))}
    </>
  );
};

export const Header = () => {
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const burgerMenuRef = useRef<HTMLDivElement>(null);
  useOutsideClick(
    burgerMenuRef,
    useCallback(() => setIsDrawerOpen(false), []),
  );

  return (
    <div className="sticky top-0 navbar bg-base-100 shadow-md px-4 z-20">
      <div className="navbar-start">
        {/* Mobile menu */}
        <div className="lg:hidden dropdown" ref={burgerMenuRef}>
          <label
            tabIndex={0}
            className="btn btn-ghost"
            onClick={() => setIsDrawerOpen(prev => !prev)}
          >
            <Bars3Icon className="h-6 w-6" />
          </label>
          {isDrawerOpen && (
            <ul
              tabIndex={0}
              className="menu menu-compact dropdown-content mt-3 p-2 shadow bg-base-100 rounded-box w-52"
              onClick={() => setIsDrawerOpen(false)}
            >
              <HeaderMenuLinks />
            </ul>
          )}
        </div>

        {/* Logo */}
        <Link href="/" passHref className="flex items-center gap-2">
          <div className="text-xl font-bold">MultiEscrow</div>
        </Link>
      </div>

      {/* Desktop menu */}
      <div className="hidden lg:flex lg:items-center lg:gap-4">
        <ul className="menu menu-horizontal px-1 gap-2">
          <HeaderMenuLinks />
        </ul>
      </div>

      {/* Connect Wallet */}
      <div className="navbar-end">
        <RainbowKitCustomConnectButton />
      </div>
    </div>
  );
};
