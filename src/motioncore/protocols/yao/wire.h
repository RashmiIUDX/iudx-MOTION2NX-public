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

#pragma once

#include <memory>
#include <vector>

#include "utility/block.h"
#include "utility/fiber_condition.h"
#include "utility/typedefs.h"
#include "wire/new_wire.h"

namespace MOTION::proto::yao {

class YaoProvider;

class YaoWire : public NewWire, public ENCRYPTO::enable_wait_setup {
 public:
  YaoWire(std::size_t num_simd);
  MPCProtocol get_protocol() const noexcept override { return MPCProtocol::Yao; }
  void set_setup_ready();
  void wait_setup() const;
  ENCRYPTO::block128_vector& get_keys() { return keys_; };
  const ENCRYPTO::block128_vector& get_keys() const { return keys_; };

 private:
  // holds the the zero keys or the active keys for the garbler and evaluator,
  // respectively
  ENCRYPTO::block128_vector keys_;
  bool setup_done_;
  ENCRYPTO::FiberCondition setup_cond_;
};

using YaoWireVector = std::vector<std::shared_ptr<YaoWire>>;

}  // namespace MOTION::proto::yao