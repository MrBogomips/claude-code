# Code Quality Best Practices - Detailed Examples

## Naming Conventions

### Variables

```javascript
// Bad
const d = new Date();
const arr = users.filter(u => u.a);
const temp = calculateTotal();

// Good
const currentDate = new Date();
const activeUsers = users.filter(user => user.isActive);
const orderTotal = calculateTotal();
```

### Functions

```javascript
// Bad - unclear what it does
function process(data) { ... }
function handleIt() { ... }
function doStuff(x, y) { ... }

// Good - action + subject
function validateUserInput(input) { ... }
function calculateOrderTotal(items) { ... }
function sendPasswordResetEmail(user) { ... }
```

### Booleans

```javascript
// Bad
const open = true;
const status = false;
const flag = true;

// Good - use is/has/can/should prefixes
const isOpen = true;
const hasPermission = false;
const canEdit = true;
const shouldRefresh = true;
```

## Function Design

### Single Responsibility

```javascript
// Bad - does too many things
function processUser(user) {
  // validate
  if (!user.email) throw new Error('Email required');
  if (!user.name) throw new Error('Name required');

  // transform
  user.email = user.email.toLowerCase();
  user.createdAt = new Date();

  // save
  database.insert('users', user);

  // notify
  sendWelcomeEmail(user);
}

// Good - each function has one job
function validateUser(user) {
  if (!user.email) throw new Error('Email required');
  if (!user.name) throw new Error('Name required');
}

function prepareUserForStorage(user) {
  return {
    ...user,
    email: user.email.toLowerCase(),
    createdAt: new Date()
  };
}

function createUser(user) {
  validateUser(user);
  const prepared = prepareUserForStorage(user);
  const saved = database.insert('users', prepared);
  sendWelcomeEmail(saved);
  return saved;
}
```

### Early Returns

```javascript
// Bad - deep nesting
function getDiscount(user, order) {
  if (user) {
    if (user.isPremium) {
      if (order.total > 100) {
        return 0.2;
      } else {
        return 0.1;
      }
    } else {
      if (order.total > 100) {
        return 0.05;
      }
    }
  }
  return 0;
}

// Good - flat structure with early returns
function getDiscount(user, order) {
  if (!user) return 0;

  if (user.isPremium && order.total > 100) return 0.2;
  if (user.isPremium) return 0.1;
  if (order.total > 100) return 0.05;

  return 0;
}
```

## Error Handling

### Meaningful Errors

```javascript
// Bad
throw new Error('Error');
throw new Error('Invalid');
throw new Error('Failed');

// Good
throw new Error(`User not found: ${userId}`);
throw new Error(`Invalid email format: ${email}`);
throw new Error(`Payment failed: ${paymentResult.reason}`);
```

### Error Boundaries

```javascript
// Handle errors at the right level
async function fetchUserData(userId) {
  // Let network errors propagate - caller should handle
  const response = await fetch(`/api/users/${userId}`);

  // Handle domain-specific errors here
  if (response.status === 404) {
    return null; // User not found is expected
  }

  if (!response.ok) {
    throw new Error(`Failed to fetch user: ${response.status}`);
  }

  return response.json();
}
```

## Testing Patterns

### Test Behavior, Not Implementation

```javascript
// Bad - tests implementation details
test('adds item to internal array', () => {
  const cart = new ShoppingCart();
  cart.addItem({ id: 1, price: 10 });
  expect(cart._items.length).toBe(1); // Testing private state
});

// Good - tests behavior
test('includes added item in cart contents', () => {
  const cart = new ShoppingCart();
  const item = { id: 1, name: 'Widget', price: 10 };

  cart.addItem(item);

  expect(cart.getItems()).toContainEqual(item);
  expect(cart.getTotal()).toBe(10);
});
```

### Arrange-Act-Assert Pattern

```javascript
test('applies discount to premium users', () => {
  // Arrange
  const user = createPremiumUser();
  const order = createOrder({ total: 100 });

  // Act
  const discount = calculateDiscount(user, order);

  // Assert
  expect(discount).toBe(20);
});
```

## Common Refactoring Patterns

### Extract Method

```javascript
// Before
function printInvoice(invoice) {
  console.log('=== INVOICE ===');
  console.log(`Date: ${invoice.date}`);
  console.log(`Customer: ${invoice.customer.name}`);

  let total = 0;
  for (const item of invoice.items) {
    const itemTotal = item.quantity * item.price;
    console.log(`${item.name}: ${itemTotal}`);
    total += itemTotal;
  }

  console.log(`Total: ${total}`);
}

// After
function printInvoice(invoice) {
  printHeader(invoice);
  const total = printLineItems(invoice.items);
  printTotal(total);
}

function printHeader(invoice) {
  console.log('=== INVOICE ===');
  console.log(`Date: ${invoice.date}`);
  console.log(`Customer: ${invoice.customer.name}`);
}

function printLineItems(items) {
  let total = 0;
  for (const item of items) {
    const itemTotal = item.quantity * item.price;
    console.log(`${item.name}: ${itemTotal}`);
    total += itemTotal;
  }
  return total;
}

function printTotal(total) {
  console.log(`Total: ${total}`);
}
```

### Replace Magic Numbers

```javascript
// Before
if (response.status === 429) {
  await sleep(60000);
  retry();
}

// After
const HTTP_TOO_MANY_REQUESTS = 429;
const RATE_LIMIT_DELAY_MS = 60_000;

if (response.status === HTTP_TOO_MANY_REQUESTS) {
  await sleep(RATE_LIMIT_DELAY_MS);
  retry();
}
```
