/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "all_collection.h"

namespace kraken::binding::jsc {

JSValueRef JSAllCollection::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getAllCollectionPropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch(property) {
    case AllCollectionProperty::kItem:
      return m_item.function();
    case AllCollectionProperty::kAdd:
      return m_add.function();
    case AllCollectionProperty::kRemove:
      return m_remove.function();
    case AllCollectionProperty::kLength:
      return JSValueMakeNumber(ctx, m_nodes.size());
    }
  }

  return HostObject::getProperty(name, exception);
}

std::vector<JSStringRef> &JSAllCollection::getAllCollectionPropertyNames() {
  static std::vector<JSStringRef> propertyNames {
    JSStringCreateWithUTF8CString("item"),
    JSStringCreateWithUTF8CString("add"),
    JSStringCreateWithUTF8CString("remove"),
    JSStringCreateWithUTF8CString("length"),
  };
  return propertyNames;
}

std::unordered_map<std::string, JSAllCollection::AllCollectionProperty> &JSAllCollection::getAllCollectionPropertyMap() {
  static std::unordered_map<std::string, AllCollectionProperty> propertyMap {
    {"item", AllCollectionProperty::kItem},
    {"add", AllCollectionProperty::kAdd},
    {"remove", AllCollectionProperty::kRemove},
    {"length", AllCollectionProperty::kLength}
  };
  return propertyMap;
}

JSValueRef JSAllCollection::item(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    return nullptr;
  }

  size_t index = JSValueToNumber(ctx, arguments[0], exception);
  auto collection = reinterpret_cast<JSAllCollection*>(JSObjectGetPrivate(function));

  if (index >= collection->m_nodes.size()) {
    return nullptr;
  }

  auto node = collection->m_nodes[index];
  return node->object;
}

JSValueRef JSAllCollection::add(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute add() on HTMLAllCollection: 1 arguments required.", exception);
    return nullptr;
  }

  if (!JSValueIsObject(ctx, arguments[0])) {
    JSC_THROW_ERROR(ctx, "Failed to execute add() on HTMLAllCollection: first arguments should be a object.", exception);
    return nullptr;
  }

  JSObjectRef nodeRef = JSValueToObject(ctx, arguments[0], exception);
  JSObjectRef beforeRef = nullptr;

  if (argumentCount == 2 && JSValueIsObject(ctx, arguments[1])) {
    beforeRef = JSValueToObject(ctx, arguments[1], exception);
  }

  auto nodeInstance = reinterpret_cast<JSNode::NodeInstance*>(JSObjectGetPrivate(nodeRef));
  auto collection = reinterpret_cast<JSAllCollection*>(JSObjectGetPrivate(function));
  JSNode::NodeInstance *beforeInstance = nullptr;

  if (beforeRef != nullptr) {
    beforeInstance = reinterpret_cast<JSNode::NodeInstance *>(JSObjectGetPrivate(nodeRef));
  }

  collection->internalAdd(nodeInstance, beforeInstance);

  return nullptr;
}

JSValueRef JSAllCollection::remove(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute remove() on HTMLAllCollection: 1 arguments required.", exception);
    return nullptr;
  }

  size_t index = JSValueToNumber(ctx, arguments[0], exception);
  auto collection = reinterpret_cast<JSAllCollection*>(JSObjectGetPrivate(function));

  collection->m_nodes.erase(collection->m_nodes.begin() + index);

  return nullptr;
}

void JSAllCollection::internalAdd(JSNode::NodeInstance *node, JSNode::NodeInstance *before) {
  if (before != nullptr) {
    auto it = std::find(m_nodes.begin(), m_nodes.end(), before);
    m_nodes.erase(it);
    m_nodes.insert(it, node);
  } else {
    m_nodes.emplace_back(node);
  }

}

}