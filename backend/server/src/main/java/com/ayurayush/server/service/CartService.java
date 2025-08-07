package com.ayurayush.server.service;

import com.ayurayush.server.entity.CartItem;
import com.ayurayush.server.entity.User;
import com.ayurayush.server.repository.CartItemRepository;
import com.ayurayush.server.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class CartService {
    @Autowired
    private CartItemRepository cartItemRepository;

    @Autowired
    private UserRepository userRepository;

    public List<CartItem> getCartItems(Long userId) {
        return cartItemRepository.findByUserId(userId);
    }

    public CartItem addCartItem(CartItem cartItem) {
        // Ensure user is a managed entity
        if (cartItem.getUser() != null && cartItem.getUser().getId() != null) {
            User user = userRepository.findById(cartItem.getUser().getId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
            cartItem.setUser(user);
        } else {
            throw new IllegalArgumentException("User ID is required");
        }
        // Optionally: check if item exists, then update quantity
        List<CartItem> existing = cartItemRepository.findByUserIdAndProductId(cartItem.getUser().getId(), cartItem.getProductId());
        if (!existing.isEmpty()) {
            CartItem item = existing.get(0);
            item.setQuantity(item.getQuantity() + cartItem.getQuantity());
            return cartItemRepository.save(item);
        }
        return cartItemRepository.save(cartItem);
    }

    public CartItem updateCartItem(Long cartItemId, int quantity) {
        Optional<CartItem> itemOpt = cartItemRepository.findById(cartItemId);
        if (itemOpt.isPresent()) {
            CartItem item = itemOpt.get();
            item.setQuantity(quantity);
            return cartItemRepository.save(item);
        }
        return null;
    }

    @Transactional
    public void deleteCartItem(Long userId, Long productId) {
        cartItemRepository.deleteByUserIdAndProductId(userId, productId);
    }
}
