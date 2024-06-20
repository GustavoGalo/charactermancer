/*
  Warnings:

  - You are about to drop the column `salt` on the `User` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[email]` on the table `User` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "ValueType" AS ENUM ('number', 'string', 'boolean');

-- AlterTable
ALTER TABLE "User" DROP COLUMN "salt";

-- CreateTable
CREATE TABLE "Object" (
    "name" TEXT NOT NULL,
    "type" "ValueType" NOT NULL,
    "id" TEXT NOT NULL,
    "valueId" TEXT NOT NULL,
    "successorId" TEXT,

    CONSTRAINT "Object_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Value" (
    "id" TEXT NOT NULL,
    "value" TEXT NOT NULL,

    CONSTRAINT "Value_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Object_valueId_key" ON "Object"("valueId");

-- CreateIndex
CREATE UNIQUE INDEX "Object_successorId_key" ON "Object"("successorId");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- AddForeignKey
ALTER TABLE "Object" ADD CONSTRAINT "Object_valueId_fkey" FOREIGN KEY ("valueId") REFERENCES "Value"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Object" ADD CONSTRAINT "Object_successorId_fkey" FOREIGN KEY ("successorId") REFERENCES "Object"("id") ON DELETE SET NULL ON UPDATE CASCADE;
