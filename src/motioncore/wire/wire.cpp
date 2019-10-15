// MIT License
//
// Copyright (c) 2019 Oleksandr Tkachenko
// Cryptography and Privacy Engineering Group (ENCRYPTO)
// TU Darmstadt, Germany
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

#include "wire.h"

#include "fmt/format.h"

#include "base/backend.h"
#include "base/register.h"
#include "gate/gate.h"
#include "utility/condition.h"

namespace MOTION::Wires {

std::size_t Wire::GetNumOfSIMDValues() const { return n_simd_; }

Wire::Wire() {
  is_done_condition_ = std::make_shared<ENCRYPTO::Condition>([this]() { return IsReady().load(); });
}

Wire::~Wire() { assert(wire_id_ >= 0); }

void Wire::RegisterWaitingGate(std::size_t gate_id) {
  std::scoped_lock lock(mutex_);
  waiting_gate_ids_.insert(gate_id);
}

void Wire::SetOnlineFinished() {
  assert(wire_id_ >= 0);
  if (is_done_) {
    throw(std::runtime_error(
        fmt::format("Marking wire #{} as \"online phase ready\" twice", wire_id_)));
  }
  {
    std::scoped_lock lock(is_done_condition_->GetMutex());
    is_done_ = true;
  }
  is_done_condition_->NotifyAll();

  for (auto gate_id : waiting_gate_ids_) {
    Wire::SignalReadyToDependency(gate_id, backend_);
  }
}

const std::atomic<bool> &Wire::IsReady() const noexcept {
  if (is_constant_) {
    return is_constant_;
  } else {
    return is_done_;
  }
}

std::string Wire::PrintIds(const std::vector<std::shared_ptr<Wires::Wire>> &wires) {
  std::string result;
  for (auto &w : wires) {
    result.append(fmt::format("{} ", w->GetWireId()));
  }
  result.erase(result.end() - 1);
  return result;
}

void Wire::SignalReadyToDependency(std::size_t gate_id, std::weak_ptr<Backend> backend) {
  auto ptr_backend = backend.lock();
  assert(ptr_backend);
  auto gate = ptr_backend->GetGate(gate_id);
  assert(gate != nullptr);
  gate->SignalDependencyIsReady();
}

void Wire::InitializationHelper() {
  auto ptr_backend = backend_.lock();
  assert(ptr_backend);
  wire_id_ = ptr_backend->GetRegister()->NextWireId();
}

}