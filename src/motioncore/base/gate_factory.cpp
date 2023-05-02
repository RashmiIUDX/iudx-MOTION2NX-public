// MIT License
//
// Copyright (c) 2020 Lennart Braun
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "gate_factory.h"

#include <stdexcept>

#include <fmt/format.h>

namespace MOTION {

GateFactory::~GateFactory() = default;

// Boolean inputs
std::pair<ENCRYPTO::ReusableFiberPromise<BitValues>, WireVector>
GateFactory::make_boolean_input_gate_my(std::size_t, std::size_t, std::size_t) {
  throw std::logic_error(fmt::format("{} does not support Boolean inputs", get_provider_name()));
}

WireVector GateFactory::make_boolean_input_gate_other(std::size_t, std::size_t, std::size_t) {
  throw std::logic_error(fmt::format("{} does not support Boolean inputs", get_provider_name()));
}

// arithmetic inputs
std::pair<ENCRYPTO::ReusableFiberPromise<IntegerValues<std::uint8_t>>, WireVector>
GateFactory::make_arithmetic_8_input_gate_my(std::size_t, std::size_t) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 8 bit inputs", get_provider_name()));
}
std::pair<ENCRYPTO::ReusableFiberPromise<IntegerValues<std::uint16_t>>, WireVector>
GateFactory::make_arithmetic_16_input_gate_my(std::size_t, std::size_t) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 16 bit inputs", get_provider_name()));
}
std::pair<ENCRYPTO::ReusableFiberPromise<IntegerValues<std::uint32_t>>, WireVector>
GateFactory::make_arithmetic_32_input_gate_my(std::size_t, std::size_t) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 32 bit inputs", get_provider_name()));
}
std::pair<ENCRYPTO::ReusableFiberPromise<IntegerValues<std::uint64_t>>, WireVector>
GateFactory::make_arithmetic_64_input_gate_my(std::size_t, std::size_t) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 64 bit inputs", get_provider_name()));
}

WireVector GateFactory::make_arithmetic_8_input_gate_other(std::size_t, std::size_t) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 8 bit inputs", get_provider_name()));
}
WireVector GateFactory::make_arithmetic_16_input_gate_other(std::size_t, std::size_t) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 16 bit inputs", get_provider_name()));
}
WireVector GateFactory::make_arithmetic_32_input_gate_other(std::size_t, std::size_t) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 32 bit inputs", get_provider_name()));
}
WireVector GateFactory::make_arithmetic_64_input_gate_other(std::size_t, std::size_t) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 64 bit inputs", get_provider_name()));
}

//Input gates to take shares directly

std::pair<std::vector<ENCRYPTO::ReusableFiberPromise<MOTION::IntegerValues<uint8_t>>>, WireVector >
GateFactory::make_arithmetic_8_input_gate_shares(std::size_t num_simd) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 8 bit inputs", get_provider_name()));
}

std::pair<std::vector<ENCRYPTO::ReusableFiberPromise<MOTION::IntegerValues<uint16_t>>>, WireVector >
GateFactory::make_arithmetic_16_input_gate_shares(std::size_t num_simd) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 16 bit inputs", get_provider_name()));
}

std::pair<std::vector<ENCRYPTO::ReusableFiberPromise<MOTION::IntegerValues<uint32_t>>>, WireVector >
GateFactory::make_arithmetic_32_input_gate_shares(std::size_t num_simd) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 32 bit inputs", get_provider_name()));
}

std::pair<std::vector<ENCRYPTO::ReusableFiberPromise<MOTION::IntegerValues<uint64_t>>>, WireVector >
GateFactory::make_arithmetic_64_input_gate_shares(std::size_t num_simd) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 64 bit inputs", get_provider_name()));
}

// Boolean outputs
ENCRYPTO::ReusableFiberFuture<BitValues> GateFactory::make_boolean_output_gate_my(
    std::size_t, const WireVector&) {
  throw std::logic_error(fmt::format("{} does not support Boolean outputs", get_provider_name()));
}

std::size_t GateFactory::make_boolean_output_gate_my_wo_getting_output(
    std::size_t, const WireVector&){
      throw std::logic_error(fmt::format("{} does not support Boolean outputs", get_provider_name()));
}

void GateFactory::make_boolean_output_gate_other(std::size_t, const WireVector&) {
  throw std::logic_error(fmt::format("{} does not support Boolean outputs", get_provider_name()));
}

// arithmetic outputs
ENCRYPTO::ReusableFiberFuture<IntegerValues<std::uint8_t>>
GateFactory::make_arithmetic_8_output_gate_my(std::size_t, const WireVector&) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 8 bit outputs", get_provider_name()));
}
ENCRYPTO::ReusableFiberFuture<IntegerValues<std::uint16_t>>
GateFactory::make_arithmetic_16_output_gate_my(std::size_t, const WireVector&) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 16 bit outputs", get_provider_name()));
}
ENCRYPTO::ReusableFiberFuture<IntegerValues<std::uint32_t>>
GateFactory::make_arithmetic_32_output_gate_my(std::size_t, const WireVector&) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 32 bit outputs", get_provider_name()));
}
ENCRYPTO::ReusableFiberFuture<IntegerValues<std::uint64_t>>
GateFactory::make_arithmetic_64_output_gate_my(std::size_t, const WireVector&) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic 64 bit outputs", get_provider_name()));
}

void GateFactory::make_arithmetic_output_gate_other(std::size_t, const WireVector&) {
  throw std::logic_error(
      fmt::format("{} does not support arithmetic outputs", get_provider_name()));
}
//-------------------------------Added below function on Feb 3----------------------------
WireVector GateFactory::make_convert_bit_to_arithmetic_beavy_gate(const WireVector& in_a) {
  throw std::logic_error(
        fmt::format("{} Should not be coming here", get_provider_name()));
  }

WireVector GateFactory::make_constMul_gate(const WireVector&,const uint64_t k, const size_t){
throw std::logic_error(
        fmt::format("{} Unable to make constMul gate.", get_provider_name()));
}
WireVector GateFactory::make_constADD_gate(const WireVector&,const uint64_t k, const size_t){
throw std::logic_error(
        fmt::format("{} Unable to make constADD gate.", get_provider_name()));
}

//-----------------------------Added below on Feb 13 ----------------------------------------
}  // namespace MOTION
