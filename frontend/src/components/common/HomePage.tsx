import React from 'react';
import {
  Container,
  Typography,
  Box,
  Button,
  Grid,
  Card,
  CardContent,
} from '@mui/material';
import {
  Store as StoreIcon,
  Security as SecurityIcon,
  Speed as SpeedIcon,
  CloudQueue as CloudIcon,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

const HomePage: React.FC = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();

  const features = [
    {
      icon: <StoreIcon sx={{ fontSize: 40 }} />,
      title: 'Wide Product Selection',
      description: 'Browse through our extensive catalog of quality products',
    },
    {
      icon: <SecurityIcon sx={{ fontSize: 40 }} />,
      title: 'Secure Authentication',
      description: 'JWT-based authentication ensures your data is safe',
    },
    {
      icon: <SpeedIcon sx={{ fontSize: 40 }} />,
      title: 'Fast & Reliable',
      description: 'Microservices architecture for optimal performance',
    },
    {
      icon: <CloudIcon sx={{ fontSize: 40 }} />,
      title: 'Cloud-Ready',
      description: 'Built with Docker and containerization in mind',
    },
  ];

  return (
    <Box>
      {/* Hero Section */}
      <Box
        sx={{
          bgcolor: 'primary.main',
          color: 'white',
          py: 10,
          textAlign: 'center',
        }}
      >
        <Container maxWidth="md">
          <Typography variant="h2" component="h1" gutterBottom fontWeight="bold">
            Welcome to Microservices Store
          </Typography>
          <Typography variant="h5" sx={{ mb: 4, opacity: 0.9 }}>
            A modern e-commerce platform built with microservices architecture
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, justifyContent: 'center' }}>
            {isAuthenticated ? (
              <Button
                variant="contained"
                size="large"
                onClick={() => navigate('/products')}
                sx={{ bgcolor: 'white', color: 'primary.main', '&:hover': { bgcolor: 'grey.100' } }}
              >
                Browse Products
              </Button>
            ) : (
              <>
                <Button
                  variant="contained"
                  size="large"
                  onClick={() => navigate('/register')}
                  sx={{ bgcolor: 'white', color: 'primary.main', '&:hover': { bgcolor: 'grey.100' } }}
                >
                  Get Started
                </Button>
                <Button
                  variant="outlined"
                  size="large"
                  onClick={() => navigate('/login')}
                  sx={{ borderColor: 'white', color: 'white', '&:hover': { borderColor: 'grey.300' } }}
                >
                  Login
                </Button>
              </>
            )}
          </Box>
        </Container>
      </Box>

      {/* Features Section */}
      <Container maxWidth="lg" sx={{ py: 8 }}>
        <Typography variant="h3" component="h2" textAlign="center" gutterBottom>
          Why Choose Us?
        </Typography>
        <Typography variant="body1" textAlign="center" color="text.secondary" sx={{ mb: 6 }}>
          Built with cutting-edge technology and best practices
        </Typography>

        <Grid container spacing={4}>
          {features.map((feature, index) => (
            <Grid item xs={12} sm={6} md={3} key={index}>
              <Card sx={{ height: '100%', textAlign: 'center', p: 2 }}>
                <CardContent>
                  <Box sx={{ color: 'primary.main', mb: 2 }}>
                    {feature.icon}
                  </Box>
                  <Typography variant="h6" gutterBottom>
                    {feature.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {feature.description}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Container>

      {/* Tech Stack Section */}
      <Box sx={{ bgcolor: 'grey.100', py: 8 }}>
        <Container maxWidth="md">
          <Typography variant="h4" component="h2" textAlign="center" gutterBottom>
            Powered By Modern Technology
          </Typography>
          <Typography variant="body1" textAlign="center" color="text.secondary" sx={{ mb: 4 }}>
            Spring Boot • React • TypeScript • Material-UI • Docker • Kubernetes • Kafka • Redis
          </Typography>
          <Box sx={{ textAlign: 'center' }}>
            <Button
              variant="contained"
              size="large"
              onClick={() => navigate('/products')}
            >
              Start Shopping
            </Button>
          </Box>
        </Container>
      </Box>
    </Box>
  );
};

export default HomePage;
