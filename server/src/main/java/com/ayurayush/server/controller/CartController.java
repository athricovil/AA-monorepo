package com.ayurayush.server.controller;

import com.ayurayush.server.entity.CartItem;
import com.ayurayush.server.entity.User;
import com.ayurayush.server.repository.UserRepository;
import com.ayurayush.server.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cart")
public class CartController {
    @Autowired
    private CartService cartService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/{userId}")
    public List<CartItem> getCart(@PathVariable Long userId) {
        return cartService.getCartItems(userId);
    }

    @PostMapping
    public CartItem addToCart(@RequestBody AddCartItemRequest req) {
        if (req.getUserId() == null || req.getProductId() == null) {
            throw new IllegalArgumentException("userId and productId are required");
        }
        User user = userRepository.findById(req.getUserId())
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        CartItem cartItem = new CartItem();
        cartItem.setUser(user);
        cartItem.setProductId(req.getProductId());
        cartItem.setQuantity(req.getQuantity() != null ? req.getQuantity() : 1);
        return cartService.addCartItem(cartItem);
    }

    @PutMapping("/{cartItemId}")
    public CartItem updateCartItem(@PathVariable Long cartItemId, @RequestParam int quantity) {
        return cartService.updateCartItem(cartItemId, quantity);
    }

    @DeleteMapping
    public void deleteCartItem(@RequestParam Long userId, @RequestParam Long productId) {
        cartService.deleteCartItem(userId, productId);
    }
}
