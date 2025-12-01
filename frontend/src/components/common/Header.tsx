import React from 'react';
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  IconButton,
  Badge,
  Box,
  Menu,
  MenuItem,
} from '@mui/material';
import {
  ShoppingCart as ShoppingCartIcon,
  AccountCircle as AccountCircleIcon,
  Store as StoreIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import { useCart } from '../../contexts/CartContext';

const Header: React.FC = () => {
  const navigate = useNavigate();
  const { user, logout, isAuthenticated } = useAuth();
  const { getTotalItems } = useCart();
  const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null);

  const handleMenu = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = async () => {
    handleClose();
    await logout();
  };

  return (
    <AppBar position="sticky">
      <Toolbar>
        <IconButton
          size="large"
          edge="start"
          color="inherit"
          aria-label="home"
          sx={{ mr: 2 }}
          onClick={() => navigate('/')}
        >
          <StoreIcon />
        </IconButton>
        
        <Typography
          variant="h6"
          component="div"
          sx={{ flexGrow: 1, cursor: 'pointer' }}
          onClick={() => navigate('/')}
        >
          Microservices Store
        </Typography>

        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Button color="inherit" onClick={() => navigate('/products')}>
            Products
          </Button>

          {isAuthenticated ? (
            <>
              <IconButton
                color="inherit"
                onClick={() => navigate('/cart')}
                aria-label={`${getTotalItems()} items in cart`}
              >
                <Badge badgeContent={getTotalItems()} color="error">
                  <ShoppingCartIcon />
                </Badge>
              </IconButton>

              <IconButton
                size="large"
                aria-label="account of current user"
                aria-controls="menu-appbar"
                aria-haspopup="true"
                onClick={handleMenu}
                color="inherit"
              >
                <AccountCircleIcon />
              </IconButton>
              <Menu
                id="menu-appbar"
                anchorEl={anchorEl}
                anchorOrigin={{
                  vertical: 'top',
                  horizontal: 'right',
                }}
                keepMounted
                transformOrigin={{
                  vertical: 'top',
                  horizontal: 'right',
                }}
                open={Boolean(anchorEl)}
                onClose={handleClose}
              >
                <MenuItem disabled>
                  <Typography variant="body2" color="text.secondary">
                    {user?.username}
                  </Typography>
                </MenuItem>
                <MenuItem onClick={() => { handleClose(); navigate('/profile'); }}>
                  My Profile
                </MenuItem>
                <MenuItem onClick={() => { handleClose(); navigate('/orders'); }}>
                  My Orders
                </MenuItem>
                <MenuItem onClick={handleLogout}>Logout</MenuItem>
              </Menu>
            </>
          ) : (
            <>
              <Button color="inherit" onClick={() => navigate('/login')}>
                Login
              </Button>
              <Button
                color="inherit"
                variant="outlined"
                onClick={() => navigate('/register')}
                sx={{ borderColor: 'white' }}
              >
                Register
              </Button>
            </>
          )}
        </Box>
      </Toolbar>
    </AppBar>
  );
};

export default Header;
